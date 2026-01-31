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
      position: Vector2(size.x / 2, 45),
      anchor: Anchor.center,
    ));

    add(scoreText = TextComponent(
      text: '0',
      textRenderer: GameStyles.valueLarge,
      position: Vector2(size.x / 2, 110),
      anchor: Anchor.center,
    ));

    add(targetText = TextComponent(
      text: 'Target: 0',
      textRenderer: GameStyles.label,
      position: Vector2(size.x / 2, 145),
      anchor: Anchor.center,
    ));

    add(handsText = TextComponent(
      text: '0',
      textRenderer: GameStyles.valueSmall,
      position: Vector2(size.x / 2, 210),
      anchor: Anchor.center,
    ));

    add(discardsText = TextComponent(
      text: '0',
      textRenderer: GameStyles.valueSmall,
      position: Vector2(size.x / 2, 260),
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
    _drawStatPill(canvas, Offset(size.x / 2, 45), 'MONEY', Colors.orange.shade700);

    // Score Box
    final scoreBox = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.x / 2, 125), width: 160, height: 80),
      const Radius.circular(8),
    );
    canvas.drawRRect(scoreBox, Paint()..color = Colors.red.shade900.withOpacity(0.8));
    canvas.drawRRect(scoreBox, Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke);
    
    GameStyles.label.render(canvas, 'SCORE', Vector2(size.x / 2, 95), anchor: Anchor.center);

    // Hands Pill
    _drawStatPill(canvas, Offset(size.x / 2, 210), 'HANDS', Colors.blue.shade700);
    
    // Discards Pill
    _drawStatPill(canvas, Offset(size.x / 2, 260), 'DISCARDS', Colors.red.shade700);
  }

  void _drawStatPill(Canvas canvas, Offset center, String label, Color color) {
    final pillRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 160, height: 36),
      const Radius.circular(4),
    );
    canvas.drawRRect(pillRect, Paint()..color = color);
    canvas.drawRRect(pillRect, Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke);
    
    final labelPainter = GameStyles.label;
    labelPainter.render(canvas, label, Vector2(center.dx - 70, center.dy), anchor: Anchor.centerLeft);
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
