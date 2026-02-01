import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle, FontWeight, TextStyle;
import '../../boolatro_component.dart';
import '../../styles.dart';
import '../action_panel.dart';

class CashoutStageComponent extends BoolatroComponent {
  late final TextComponent titleText;
  late final TextComponent scoreText;
  late final TextComponent rewardText;
  late final GameButton collectButton;

  @override
  Future<void> onLoad() async {
    titleText = TextComponent(
      text: 'CASHOUT',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.green,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
      anchor: Anchor.center,
    );

    scoreText = TextComponent(
      text: '',
      textRenderer: GameStyles.valueSmall,
      anchor: Anchor.center,
    );

    rewardText = TextComponent(
      text: '',
      textRenderer: GameStyles.valueSmall,
      anchor: Anchor.center,
    );

    collectButton = GameButton(
      label: 'COLLECT',
      color: Colors.green,
      onPressed: () => runState.cashOutAndGoToShop(),
    )
      ..size = Vector2(200, 50)
      ..anchor = Anchor.center;

    addAll([titleText, scoreText, rewardText, collectButton]);
    onStateChanged();
  }

  @override
  void onStateChanged() {
    if (!isLoaded) return;
    _layout();
    
    final proof = runState.proofState;
    final reward = (proof.blindScore / 10).floor();
    scoreText.text = 'BLIND SCORE: ${proof.blindScore}';
    rewardText.text = 'TOTAL REWARD: \$$reward';
  }

  void _layout() {
    titleText.position = Vector2(size.x / 2, 60);
    scoreText.position = Vector2(size.x / 2, 130);
    rewardText.position = Vector2(size.x / 2, 170);
    collectButton.position = Vector2(size.x / 2, 250);
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
