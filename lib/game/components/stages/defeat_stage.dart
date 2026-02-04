import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart' show Colors, Offset, Shadow, TextStyle, FontWeight;
import '../../boolatro_component.dart';
import '../game_button.dart';

class DefeatStageComponent extends BoolatroComponent {
  late final BoolatroTextComponent titleText;
  late final BoolatroTextComponent scoreText;
  late final GameButton continueButton;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    titleText = BoolatroTextComponent(
      text: 'DEFEAT',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 96,
          fontWeight: FontWeight.w900,
          letterSpacing: 16,
          shadows: [
            Shadow(color: Colors.red, offset: Offset(6, 6)),
            Shadow(color: Colors.black, offset: Offset(8, 8)),
          ],
        ),
      ),
      anchor: Anchor.center,
    );

    scoreText = BoolatroTextComponent(
      text: 'BLIND NOT CLEARED',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.red.shade400,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
      anchor: Anchor.center,
    );

    continueButton = GameButton(
      label: 'CONTINUE',
      color: Colors.red.shade900,
      onPressed: () => runState.reset(),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
    )
      ..size = Vector2(280, 80)
      ..anchor = Anchor.center;

    await addAll([titleText, scoreText, continueButton]);
  }

  @override
  void onStateChanged() {
    if (!isLoaded) return;
    _layout();
    
    final proof = runState.proofState;
    scoreText.text = 'SCORE: ${proof.blindScore} / ${proof.blindTargetScore}';
  }

  void _layout() {
    titleText.position = Vector2(size.x / 2, size.y / 2 - 120);
    scoreText.position = Vector2(size.x / 2, size.y / 2 + 20);
    continueButton.position = Vector2(size.x / 2, size.y / 2 + 150);
  }
}
