import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle;
import '../../boolatro_component.dart';
import '../../styles.dart';
import '../game_button.dart';

class OptionsOverlay extends BoolatroComponent {
  late final GameButton giveUpButton;
  late final GameButton resumeButton;
  late final PositionComponent container;

  @override
  Future<void> onLoad() async {
    size = Vector2(1920, 1080);
    
    // Background dim
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.8),
    ));

    // Content container
    final containerSize = Vector2(400, 300);
    container = PositionComponent(
      size: containerSize,
      position: size / 2,
      anchor: Anchor.center,
    );
    add(container);

    // Draw container box
    container.add(CustomRenderComponent(
      size: containerSize,
      onRender: (canvas, size) {
        final rect = RRect.fromRectAndRadius(
          size.toRect(),
          const Radius.circular(16),
        );
        canvas.drawRRect(rect, Paint()..color = Colors.blueGrey.shade900);
        canvas.drawRRect(
          rect,
          Paint()
            ..color = Colors.white24
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
      },
    ));

    // Title
    container.add(TextComponent(
      text: 'OPTIONS',
      textRenderer: GameStyles.title,
      position: Vector2(containerSize.x / 2, 60),
      anchor: Anchor.center,
    ));

    // Resume Button
    container.add(resumeButton = GameButton(
      label: 'RESUME',
      color: Colors.teal.shade700,
      onPressed: () => runState.showOptions = false,
    )
      ..size = Vector2(300, 60)
      ..position = Vector2(containerSize.x / 2, 160)
      ..anchor = Anchor.center);

    // Give Up Button
    container.add(giveUpButton = GameButton(
      label: 'GIVE UP',
      color: Colors.red.shade900,
      onPressed: () => runState.giveUp(),
    )
      ..size = Vector2(300, 60)
      ..position = Vector2(containerSize.x / 2, 240)
      ..anchor = Anchor.center);
  }
}

class CustomRenderComponent extends PositionComponent {
  final void Function(Canvas canvas, Vector2 size) onRender;

  CustomRenderComponent({
    required Vector2 size,
    required this.onRender,
  }) : super(size: size);

  @override
  void render(Canvas canvas) {
    onRender(canvas, size);
  }
}
