import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart' show Colors, Offset, Shadow, TextStyle, FontWeight;
import '../../boolatro_component.dart';
import '../../styles.dart';
import '../action_panel.dart';
// import '../../../state/run_state.dart'; (Removed unused import)

class StartStageComponent extends BoolatroComponent {
  late final TextComponent titleText;
  late final TextComponent subtitleText;
  late final GameButton startButton;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    titleText = TextComponent(
      text: 'BOOLATRO',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 72,
          fontWeight: FontWeight.w900,
          letterSpacing: 12,
          shadows: [
            Shadow(color: Colors.red, offset: Offset(4, 4)),
            Shadow(color: Colors.blue, offset: Offset(-4, -4)),
          ],
        ),
      ),
      anchor: Anchor.center,
    );

    subtitleText = TextComponent(
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
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    )
      ..size = Vector2(200, 60)
      ..anchor = Anchor.center;

    await addAll([titleText, subtitleText, startButton]);
    _layout();
  }

  void _layout() {
    titleText.position = Vector2(size.x / 2, size.y / 2 - 120);
    subtitleText.position = Vector2(size.x / 2, size.y / 2 - 40);
    startButton.position = Vector2(size.x / 2, size.y / 2 + 80);
  }
}
