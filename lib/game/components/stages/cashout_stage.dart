import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle, FontWeight, TextStyle;
import '../../boolatro_component.dart';
import '../../styles.dart';
import '../action_panel.dart';

class CashoutStageComponent extends BoolatroComponent {
  @override
  Future<void> onLoad() async {
    final proof = runState.proofState;
    final reward = (proof.blindScore / 10).floor();

    add(TextComponent(
      text: 'CASHOUT',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.green,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
      position: Vector2(size.x / 2, 60),
      anchor: Anchor.center,
    ));

    add(TextComponent(
      text: 'BLIND SCORE: ${proof.blindScore}',
      textRenderer: GameStyles.valueSmall,
      position: Vector2(size.x / 2, 130),
      anchor: Anchor.center,
    ));

    add(TextComponent(
      text: 'TOTAL REWARD: \$$reward',
      textRenderer: GameStyles.valueSmall,
      position: Vector2(size.x / 2, 170),
      anchor: Anchor.center,
    ));

    add(GameButton(
      label: 'COLLECT',
      color: Colors.green,
      onPressed: () => runState.cashOutAndGoToShop(),
    )
      ..size = Vector2(200, 50)
      ..position = Vector2(size.x / 2, 250)
      ..anchor = Anchor.center);
  }

  @override
  void render(Canvas canvas) {
    final boxRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.x / 2, 160), width: 280, height: 120),
      const Radius.circular(16),
    );
    canvas.drawRRect(boxRect, Paint()..color = Colors.black.withOpacity(0.6));
    canvas.drawRRect(boxRect, Paint()
      ..color = Colors.green.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3);
  }
}
