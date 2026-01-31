import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle, Canvas;
import '../boolatro_component.dart';
import '../../state/run_state.dart';
import 'stages/start_stage.dart';
import 'stages/select_blind_stage.dart';
import 'stages/proof_stage.dart';
import 'stages/cashout_stage.dart';
import 'stages/shop_stage.dart';

class StageComponent extends BoolatroComponent {
  PositionComponent? _currentStage;
  GamePhase? _lastPhase;

  @override
  void onStateChanged() {
    if (!isLoaded) return;
    if (_lastPhase != runState.phase) {
      _lastPhase = runState.phase;
      _updateStage();
    }
  }

  void _updateStage() {
    if (_currentStage != null) {
      remove(_currentStage!);
    }

    switch (runState.phase) {
      case GamePhase.start:
        _currentStage = StartStageComponent();
        break;
      case GamePhase.selectBlind:
        _currentStage = SelectBlindStageComponent();
        break;
      case GamePhase.proof:
        _currentStage = ProofStageComponent();
        break;
      case GamePhase.cashout:
        _currentStage = CashoutStageComponent();
        break;
      case GamePhase.shop:
        _currentStage = ShopStageComponent();
        break;
    }

    if (_currentStage != null) {
      _currentStage!.size = size;
      add(_currentStage!);
    }
  }

  @override
  void render(Canvas canvas) {
    // No box rendering for Stage to maintain seamless look across phases
  }
}
