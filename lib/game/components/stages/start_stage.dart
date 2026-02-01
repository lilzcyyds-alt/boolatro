import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart' show Colors, Offset, Shadow, TextStyle, FontWeight;
import '../../boolatro_component.dart';
import '../../styles.dart';
import '../action_panel.dart';

class StartStageComponent extends BoolatroComponent {
  late final BoolatroTextComponent titleText;
  late final BoolatroTextComponent subtitleText;
  late final GameButton startButton;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    titleText = BoolatroTextComponent(
      text: 'BOOLATRO',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 96,
          fontWeight: FontWeight.w900,
          letterSpacing: 16,
          shadows: [
            Shadow(color: Colors.red, offset: Offset(6, 6)),
            Shadow(color: Colors.blue, offset: Offset(-6, -6)),
          ],
        ),
      ),
      anchor: Anchor.center,
    );

    subtitleText = BoolatroTextComponent(
      text: 'THE LOGIC PROOF ROGUELIKE',
      textRenderer: GameStyles.label,
      anchor: Anchor.center,
    );

    startButton = GameButton(
      label: 'BEGIN RUN',
      color: Colors.orange.shade900,
      onPressed: () => runState.advancePhase(),
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

    await addAll([titleText, subtitleText, startButton]);
  }

  @override
  void onStateChanged() {
    if (!isLoaded) return;
    _layout();
  }

  void _layout() {
    // Title position
    titleText.position = Vector2(size.x / 2, size.y / 2 - 160);
    // Subtitle position
    subtitleText.position = Vector2(size.x / 2, size.y / 2 - 40);
    // Button position
    startButton.position = Vector2(size.x / 2, size.y / 2 + 120);
  }
}
