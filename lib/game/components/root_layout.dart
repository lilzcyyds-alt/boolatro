import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, Paint;
import '../boolatro_component.dart';
import 'joker_row.dart';
import 'scoring_panel.dart';
import 'action_panel.dart';
import 'hand.dart';
import 'stage.dart';
import '../../state/run_state.dart';

class RootLayoutComponent extends BoolatroComponent {
  late final JokerRowComponent jokerRow;
  late final ScoringPanelComponent scoringPanel;
  late final ActionPanelComponent actionPanel;
  late final HandComponent hand;
  late final StageComponent stage;

  bool _initialized = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    jokerRow = JokerRowComponent();
    scoringPanel = ScoringPanelComponent();
    actionPanel = ActionPanelComponent();
    hand = HandComponent();
    stage = StageComponent();
    
    addAll([jokerRow, scoringPanel, actionPanel, hand, stage]);
    _initialized = true;
    _layout();
  }

  void _layout() {
    if (!_initialized) return;

    // virtual size based on current size
    final virtualWidth = size.x;
    final virtualHeight = size.y;

    if (virtualWidth <= 0 || virtualHeight <= 0) return;

    const jokerRowHeight = 80.0;
    const scoringPanelWidth = 170.0;
    const actionPanelWidth = 170.0;
    const handHeight = 150.0;

    final isStartPhase = runState.phase == GamePhase.start;

    // Always keep panels active in the tree, but sub-components handle their internal content visibility.
    jokerRow.isVisible = true;
    scoringPanel.isVisible = true;
    actionPanel.isVisible = true;
    hand.isVisible = true;

    jokerRow.position = Vector2(0, 0);
    jokerRow.size = Vector2(virtualWidth, jokerRowHeight);

    scoringPanel.position = Vector2(0, jokerRowHeight);
    scoringPanel.size = Vector2(scoringPanelWidth, virtualHeight - jokerRowHeight - handHeight);

    actionPanel.position = Vector2(virtualWidth - actionPanelWidth, jokerRowHeight);
    actionPanel.size = Vector2(actionPanelWidth, virtualHeight - jokerRowHeight - handHeight);

    hand.position = Vector2(0, virtualHeight - handHeight);
    hand.size = Vector2(virtualWidth, handHeight);

    stage.position = Vector2(scoringPanelWidth, jokerRowHeight);
    stage.size = Vector2(virtualWidth - scoringPanelWidth - actionPanelWidth,
        virtualHeight - jokerRowHeight - handHeight);
  }

  @override
  void render(Canvas canvas) {
    // Fill the 16:9 area with a base background color
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFF0B0B0B));

    // Optional: Render faint sidebar dividers even in Start phase to anchor 16:9 look
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Left divider
    canvas.drawLine(const Offset(170, 80), Offset(170, size.y - 150), paint);
    // Right divider
    canvas.drawLine(Offset(size.x - 170, 80), Offset(size.x - 170, size.y - 150), paint);
  }

  @override
  void onStateChanged() {
    if (!isLoaded) return;
    _layout();
  }
}
