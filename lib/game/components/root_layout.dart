import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, Paint, LinearGradient, Alignment;
import '../boolatro_component.dart';
import 'joker_row.dart';
import 'scoring_panel.dart';
import 'action_panel.dart';
import 'hand.dart';
import 'stage.dart';
import 'phase_info.dart';
import '../../state/run_state.dart';
import '../styles.dart';

class RootLayoutComponent extends BoolatroComponent {
  late final PhaseInfoComponent phaseInfo;
  late final JokerRowComponent jokerRow;
  late final ScoringPanelComponent scoringPanel;
  late final ActionPanelComponent actionPanel;
  late final HandComponent hand;
  late final StageComponent stage;

  bool _initialized = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(UIConfig.screenWidth, UIConfig.screenHeight);
    
    phaseInfo = PhaseInfoComponent()..size = Vector2(UIConfig.phaseInfoWidth, UIConfig.phaseInfoHeight);
    jokerRow = JokerRowComponent()..size = Vector2(UIConfig.jokerRowWidth, UIConfig.jokerRowHeight);
    scoringPanel = ScoringPanelComponent()..size = Vector2(UIConfig.scoringPanelWidth, UIConfig.scoringPanelHeight);
    actionPanel = ActionPanelComponent()..size = Vector2(UIConfig.actionPanelWidth, UIConfig.actionPanelHeight);
    hand = HandComponent()..size = Vector2(UIConfig.handWidth, UIConfig.handHeight);
    stage = StageComponent()..size = Vector2(UIConfig.screenWidth, UIConfig.screenHeight);
    
    addAll([phaseInfo, jokerRow, scoringPanel, actionPanel, hand, stage]);
  }

  void _layout() {
    if (!isLoaded) return;

    final isCleanPhase = runState.phase == GamePhase.start || runState.phase == GamePhase.defeat;

    // target positions in 1080p space based on UIConfig
    final targetPhaseInfoPos = UIConfig.phaseInfoPos;
    final targetJokerPos = UIConfig.jokerRowPos;
    final targetScoringPos = UIConfig.scoringPanelPos;
    final targetActionPos = UIConfig.actionPanelPos;
    final targetHandPos = UIConfig.handPos;
    
    // Stage container itself stays at (0,0) and full screen
    final targetStagePos = Vector2.zero();

    if (!_initialized) {
      phaseInfo.position = isCleanPhase ? UIConfig.getRandomOffscreenPosition() : targetPhaseInfoPos;
      phaseInfo.isVisible = !isCleanPhase;

      jokerRow.position = isCleanPhase ? UIConfig.getRandomOffscreenPosition() : targetJokerPos;
      jokerRow.isVisible = !isCleanPhase;
      
      scoringPanel.position = isCleanPhase ? UIConfig.getRandomOffscreenPosition() : targetScoringPos;
      scoringPanel.isVisible = !isCleanPhase;
      
      actionPanel.position = isCleanPhase ? UIConfig.getRandomOffscreenPosition() : targetActionPos;
      actionPanel.isVisible = !isCleanPhase;
      
      hand.position = isCleanPhase ? UIConfig.getRandomOffscreenPosition() : targetHandPos;
      hand.isVisible = !isCleanPhase;
      
      stage.position = targetStagePos;
      stage.isVisible = true; 
      _initialized = true;
    } else {
      // Calculate offscreen targets for components flying OUT or origins for components flying IN
      final offscreenPos = UIConfig.getRandomOffscreenPosition();

      if (isCleanPhase) {
        // Flying OUT to random offscreen
        phaseInfo.flyTo(offscreenPos, isVisibleBefore: true, isVisibleAfter: false);
        jokerRow.flyTo(UIConfig.getRandomOffscreenPosition(), isVisibleBefore: true, isVisibleAfter: false);
        scoringPanel.flyTo(UIConfig.getRandomOffscreenPosition(), isVisibleBefore: true, isVisibleAfter: false);
        actionPanel.flyTo(UIConfig.getRandomOffscreenPosition(), isVisibleBefore: true, isVisibleAfter: false);
        hand.flyTo(UIConfig.getRandomOffscreenPosition(), isVisibleBefore: true, isVisibleAfter: false);
      } else {
        // Flying IN from current position (if it was offscreen) to target
        // If we are coming from start phase, we might want to ensure they start at a random offscreen pos
        // however flyTo usually moves from 'current' position.
        // To ensure randomness on every 'in' transition:
        if (!phaseInfo.isVisible) phaseInfo.position = UIConfig.getRandomOffscreenPosition();
        if (!jokerRow.isVisible) jokerRow.position = UIConfig.getRandomOffscreenPosition();
        if (!scoringPanel.isVisible) scoringPanel.position = UIConfig.getRandomOffscreenPosition();
        if (!actionPanel.isVisible) actionPanel.position = UIConfig.getRandomOffscreenPosition();
        if (!hand.isVisible) hand.position = UIConfig.getRandomOffscreenPosition();

        phaseInfo.flyTo(targetPhaseInfoPos, isVisibleBefore: true, isVisibleAfter: true);
        jokerRow.flyTo(targetJokerPos, isVisibleBefore: true, isVisibleAfter: true);
        scoringPanel.flyTo(targetScoringPos, isVisibleBefore: true, isVisibleAfter: true);
        actionPanel.flyTo(targetActionPos, isVisibleBefore: true, isVisibleAfter: true);
        hand.flyTo(targetHandPos, isVisibleBefore: true, isVisibleAfter: true);
      }
      // Stage doesn't move relative to root anymore
    }
  }

  @override
  void render(Canvas canvas) {
    // Fill the 16:9 area with a base background gradient
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blueGrey.shade900,
          Colors.black,
        ],
      ).createShader(size.toRect());
    
    canvas.drawRect(size.toRect(), paint);

    // Optional: Render subtle grid or dividers if needed, but the design doc emphasizes clean areas.
  }

  GamePhase? _lastPhase;

  @override
  void onMount() {
    super.onMount();
    runState.addListener(onStateChanged);
    onStateChanged();
  }

  @override
  void onRemove() {
    runState.removeListener(onStateChanged);
    super.onRemove();
  }

  @override
  void onStateChanged() {
    if (!isLoaded) return;
    if (_lastPhase == runState.phase) return;
    _lastPhase = runState.phase;
    
    print('[RootLayoutComponent] onStateChanged. Phase: ${runState.phase}');
    _layout();
  }
}
