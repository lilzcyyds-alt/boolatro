import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Canvas;
import '../boolatro_component.dart';
import '../../state/run_state.dart';
import '../styles.dart';
import 'stages/start_stage.dart';
import 'stages/select_blind_stage.dart';
import 'stages/proof_stage.dart';
import 'stages/cashout_stage.dart';
import 'stages/shop_stage.dart';

class StageComponent extends BoolatroComponent {
  final Map<GamePhase, BoolatroComponent> _stageCache = {};
  BoolatroComponent? _currentStage;
  GamePhase? _lastPhase;

  T getStage<T extends BoolatroComponent>(GamePhase phase) {
    return _stageCache[phase] as T;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(UIConfig.screenWidth, UIConfig.screenHeight);

    // Initialize all stages upfront for reuse
    _stageCache[GamePhase.start] = StartStageComponent()..size = Vector2(UIConfig.screenWidth, UIConfig.screenHeight);
    _stageCache[GamePhase.selectBlind] = SelectBlindStageComponent()..size = Vector2(UIConfig.stageWidth, UIConfig.stageHeight);
    _stageCache[GamePhase.proof] = ProofStageComponent()..size = Vector2(UIConfig.stageWidth, UIConfig.stageHeight);
    _stageCache[GamePhase.cashout] = CashoutStageComponent()..size = Vector2(UIConfig.stageWidth, UIConfig.stageHeight);
    _stageCache[GamePhase.shop] = ShopStageComponent()..size = Vector2(UIConfig.stageWidth, UIConfig.stageHeight);

    for (final stage in _stageCache.values) {
      stage.isVisible = false;
      add(stage);
    }
  }

  @override
  void onStateChanged() {
    if (!isLoaded) return;
    if (_lastPhase != runState.phase) {
      _lastPhase = runState.phase;
      _updateStage();
    }
  }

  void _updateStage() {
    final nextPhase = runState.phase;
    final nextStage = _stageCache[nextPhase];
    if (nextStage == null) return;

    final offscreenPos = Vector2(0, UIConfig.safeOffY);
    
    // Determine target Rect for the next stage based on UIConfig grid
    final bool isFullPage = nextPhase == GamePhase.start;
    final targetPos = isFullPage ? Vector2.zero() : UIConfig.stagePos;
    final targetSize = isFullPage 
        ? Vector2(UIConfig.screenWidth, UIConfig.screenHeight) 
        : Vector2(UIConfig.stageWidth, UIConfig.stageHeight);

    if (_currentStage != null && _currentStage != nextStage) {
      // Fly out current stage
      _currentStage!.flyTo(offscreenPos, isVisibleAfter: false);
    }

    nextStage.size = targetSize;
    nextStage.onStateChanged();

    if (nextStage != _currentStage) {
      nextStage.isVisible = true;
      nextStage.position = offscreenPos;
      nextStage.flyTo(targetPos);
    } else {
      // If phase changed but stage is the same, update size and position
      nextStage.flyTo(targetPos);
      nextStage.size = targetSize;
      nextStage.isVisible = true;
    }

    _currentStage = nextStage;
  }

  @override
  void render(Canvas canvas) {
    // No box rendering for Stage to maintain seamless look across phases
  }
}
