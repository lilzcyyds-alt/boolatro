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
    final targetPhaseInfoPos = isStartPhase ? Vector2(-UIConfig.safeOffX, UIConfig.phaseInfoPos.y) : UIConfig.phaseInfoPos;
    final targetJokerPos = isStartPhase ? Vector2(UIConfig.jokerRowPos.x, -UIConfig.safeOffY) : UIConfig.jokerRowPos;
    final targetScoringPos = isStartPhase ? Vector2(-UIConfig.safeOffX, UIConfig.scoringPanelPos.y) : UIConfig.scoringPanelPos;
    final targetActionPos = isStartPhase ? Vector2(UIConfig.screenWidth + UIConfig.safeOffX, UIConfig.actionPanelPos.y) : UIConfig.actionPanelPos;
    final targetHandPos = isStartPhase ? Vector2(UIConfig.handPos.x, UIConfig.screenHeight + UIConfig.safeOffY) : UIConfig.handPos;
    
    // Stage container itself stays at (0,0) and full screen
    final targetStagePos = Vector2.zero();

    if (!_initialized) {
      phaseInfo.position = targetPhaseInfoPos;
      phaseInfo.isVisible = !isStartPhase;

      jokerRow.position = targetJokerPos;
      jokerRow.isVisible = !isStartPhase;
      
      scoringPanel.position = targetScoringPos;
      scoringPanel.isVisible = !isStartPhase;
      
      actionPanel.position = targetActionPos;
      actionPanel.isVisible = !isStartPhase;
      
      hand.position = targetHandPos;
      hand.isVisible = !isStartPhase;
      
      stage.position = targetStagePos;
      stage.isVisible = true; 
      _initialized = true;
    } else {
      phaseInfo.flyTo(targetPhaseInfoPos, isVisibleBefore: true, isVisibleAfter: !isStartPhase);
      jokerRow.flyTo(targetJokerPos, isVisibleBefore: true, isVisibleAfter: !isStartPhase);
      scoringPanel.flyTo(targetScoringPos, isVisibleBefore: true, isVisibleAfter: !isStartPhase);
      actionPanel.flyTo(targetActionPos, isVisibleBefore: true, isVisibleAfter: !isStartPhase);
      hand.flyTo(targetHandPos, isVisibleBefore: true, isVisibleAfter: !isStartPhase);
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
