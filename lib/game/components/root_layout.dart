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
    _layout();
  }

  void _layout() {
    if (!isLoaded) return;

    final isStartPhase = runState.phase == GamePhase.start;

    // target positions in 1080p space based on UIConfig
    final targetPhaseInfoPos = UIConfig.phaseInfoPos;
    final targetJokerPos = UIConfig.jokerRowPos;
    final targetScoringPos = UIConfig.scoringPanelPos;
    final targetActionPos = UIConfig.actionPanelPos;
    final targetHandPos = UIConfig.handPos;
    
    // Stage container itself stays at (0,0) and full screen
    final targetStagePos = Vector2.zero();

    if (!_initialized) {
      phaseInfo.position = isStartPhase ? UIConfig.getRandomOffscreenPosition() : targetPhaseInfoPos;
      phaseInfo.isVisible = !isStartPhase;

      jokerRow.position = isStartPhase ? UIConfig.getRandomOffscreenPosition() : targetJokerPos;
      jokerRow.isVisible = !isStartPhase;
      
      scoringPanel.position = isStartPhase ? UIConfig.getRandomOffscreenPosition() : targetScoringPos;
      scoringPanel.isVisible = !isStartPhase;
      
      actionPanel.position = isStartPhase ? UIConfig.getRandomOffscreenPosition() : targetActionPos;
      actionPanel.isVisible = !isStartPhase;
      
      hand.position = isStartPhase ? UIConfig.getRandomOffscreenPosition() : targetHandPos;
      hand.isVisible = !isStartPhase;
      
      stage.position = targetStagePos;
      stage.isVisible = true; 
      _initialized = true;
    } else {
      // Calculate offscreen targets for components flying OUT or origins for components flying IN
      final offscreenPos = UIConfig.getRandomOffscreenPosition();

      if (isStartPhase) {
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

  @override
  void onStateChanged() {
    if (!isLoaded) return;
    _layout();
  }
}
