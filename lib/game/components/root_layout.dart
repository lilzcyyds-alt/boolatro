import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, Paint, LinearGradient, Alignment;
import '../boolatro_component.dart';
import 'editor_container.dart';
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
  late final EditorContainerComponent editorContainer;

  bool _initialized = false;
  bool? _lastEditorOpen;

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
    editorContainer = EditorContainerComponent()..size = Vector2(UIConfig.editorPanelWidth, UIConfig.editorPanelHeight);
    
    addAll([phaseInfo, jokerRow, scoringPanel, actionPanel, hand, stage, editorContainer]);
  }

  void _layout() {
    if (!isLoaded) return;

    final isCleanPhase = runState.phase == GamePhase.start || runState.phase == GamePhase.defeat;
    final isEditorOpen = runState.proofState.editorOpen;

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

      editorContainer.position = UIConfig.getRandomOffscreenPosition();
      editorContainer.isVisible = false;

      _initialized = true;
    } else {
      if (isCleanPhase) {
        // Flying OUT to random offscreen
        phaseInfo.flyTo(UIConfig.getRandomOffscreenPosition(), isVisibleBefore: true, isVisibleAfter: false);
        jokerRow.flyTo(UIConfig.getRandomOffscreenPosition(), isVisibleBefore: true, isVisibleAfter: false);
        scoringPanel.flyTo(UIConfig.getRandomOffscreenPosition(), isVisibleBefore: true, isVisibleAfter: false);
        actionPanel.flyTo(UIConfig.getRandomOffscreenPosition(), isVisibleBefore: true, isVisibleAfter: false);
        hand.flyTo(UIConfig.getRandomOffscreenPosition(), isVisibleBefore: true, isVisibleAfter: false);
        // editorContainer is now handled entirely by Flutter overlay - keep it hidden
        // Stage stays at 0,0 but its children might hide.
      } else if (isEditorOpen) {
        // Editor is opening: stage, actionPanel, hand fly out.
        // editorContainer is now handled entirely by Flutter overlay - keep it hidden
        // phaseInfo, scoringPanel, jokerRow stay.

        stage.flyTo(UIConfig.getRandomOffscreenPosition(), isVisibleAfter: false);
        actionPanel.flyTo(UIConfig.getRandomOffscreenPosition(), isVisibleAfter: false);
        hand.flyTo(UIConfig.getRandomOffscreenPosition(), isVisibleAfter: false);

        phaseInfo.flyTo(targetPhaseInfoPos, isVisibleBefore: true, isVisibleAfter: true);
        jokerRow.flyTo(targetJokerPos, isVisibleBefore: true, isVisibleAfter: true);
        scoringPanel.flyTo(targetScoringPos, isVisibleBefore: true, isVisibleAfter: true);
      } else {
        // Normal active phase, editor is closed.
        // stage, actionPanel, hand fly in if they were hidden/offscreen.
        // editorContainer is now handled entirely by Flutter overlay - keep it hidden

        if (!stage.isVisible) stage.position = UIConfig.getRandomOffscreenPosition();
        if (!actionPanel.isVisible) actionPanel.position = UIConfig.getRandomOffscreenPosition();
        if (!hand.isVisible) hand.position = UIConfig.getRandomOffscreenPosition();

        stage.flyTo(targetStagePos, isVisibleBefore: true, isVisibleAfter: true);
        actionPanel.flyTo(targetActionPos, isVisibleBefore: true, isVisibleAfter: true);
        hand.flyTo(targetHandPos, isVisibleBefore: true, isVisibleAfter: true);

        phaseInfo.flyTo(targetPhaseInfoPos, isVisibleBefore: true, isVisibleAfter: true);
        jokerRow.flyTo(targetJokerPos, isVisibleBefore: true, isVisibleAfter: true);
        scoringPanel.flyTo(targetScoringPos, isVisibleBefore: true, isVisibleAfter: true);
      }
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
    
    final currentEditorOpen = runState.proofState.editorOpen;
    if (_lastPhase == runState.phase && _lastEditorOpen == currentEditorOpen) return;
    
    _lastPhase = runState.phase;
    _lastEditorOpen = currentEditorOpen;
    
    print('[RootLayoutComponent] onStateChanged. Phase: ${runState.phase}, Editor: $currentEditorOpen');
    _layout();
  }
}
