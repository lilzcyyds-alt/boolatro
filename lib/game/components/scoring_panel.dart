import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle;
import '../boolatro_component.dart';
import '../styles.dart';
import '../../state/run_state.dart';

class ScoringPanelComponent extends BoolatroComponent {
  late final TextComponent moneyText;
  late final TextComponent scoreText;
  late final TextComponent targetText;
  late final TextComponent handsText;
  late final TextComponent discardsText;

  @override
  Future<void> onLoad() async {
    add(moneyText = TextComponent(
      text: '\$0',
      textRenderer: GameStyles.valueSmall,
      position: Vector2(size.x / 2, 60),
      anchor: Anchor.center,
    ));

    add(scoreText = TextComponent(
      text: '0',
      textRenderer: GameStyles.valueLarge,
      position: Vector2(size.x / 2, 160),
      anchor: Anchor.center,
    ));

    add(targetText = TextComponent(
      text: 'Target: 0',
      textRenderer: GameStyles.label,
      position: Vector2(size.x / 2, 210),
      anchor: Anchor.center,
    ));

    add(handsText = TextComponent(
      text: '0',
      textRenderer: GameStyles.valueSmall,
      position: Vector2(size.x / 2, 300),
      anchor: Anchor.center,
    ));

    add(discardsText = TextComponent(
      text: '0',
      textRenderer: GameStyles.valueSmall,
      position: Vector2(size.x / 2, 380),
      anchor: Anchor.center,
    ));

    onStateChanged();
  }

  @override
  void render(Canvas canvas) {
    if (!isVisible) return;
    if (runState.phase == GamePhase.start) return;

    // Main Panel Background
    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(12),
    );
    canvas.drawRRect(rect, Paint()..color = Colors.black.withOpacity(0.4));
    canvas.drawRRect(rect, Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);

    // Money Pill
    _drawStatPill(canvas, Offset(size.x / 2, 60), 'MONEY', GameStyles.money);

    // Score Box
    final scoreBox = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.x / 2, 180), width: 210, height: 110),
      const Radius.circular(8),
    );
    canvas.drawRRect(scoreBox, Paint()..color = GameStyles.score.withOpacity(0.8));
    canvas.drawRRect(scoreBox, Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke);
    
    GameStyles.label.render(canvas, 'SCORE', Vector2(size.x / 2, 140), anchor: Anchor.center);

    // Hands Pill
    _drawStatPill(canvas, Offset(size.x / 2, 300), 'HANDS', GameStyles.hands);
    
    // Discards Pill
    _drawStatPill(canvas, Offset(size.x / 2, 380), 'DISCARDS', GameStyles.discards);
  }

  void _drawStatPill(Canvas canvas, Offset center, String label, Color color) {
    final pillRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 210, height: 48),
      const Radius.circular(4),
    );
    canvas.drawRRect(pillRect, Paint()..color = color);
    canvas.drawRRect(pillRect, Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke);
    
    final labelPainter = GameStyles.label;
    labelPainter.render(canvas, label, Vector2(center.dx - 90, center.dy), anchor: Anchor.centerLeft);
  }

  @override
  void onStateChanged() {
    if (!isLoaded || !isVisible || runState.phase == GamePhase.start) return;
    
    final proof = runState.proofState;
    final shop = runState.shopState;

    moneyText.text = '\$${shop.money}';
    scoreText.text = '${proof.blindScore}';
    targetText.text = 'Target: ${proof.blindTargetScore}';
    handsText.text = '${proof.handsRemaining}';
    discardsText.text = '0';
  }
}
