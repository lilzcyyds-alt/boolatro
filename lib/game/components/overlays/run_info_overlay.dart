import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle;
import '../../boolatro_component.dart';
import '../../styles.dart';
import '../game_button.dart';

class RunInfoOverlay extends BoolatroComponent {
  late final GameButton closeButton;
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
    final containerSize = Vector2(1200, 800);
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
      text: 'RULE REWARD TABLE',
      textRenderer: GameStyles.title,
      position: Vector2(containerSize.x / 2, 60),
      anchor: Anchor.center,
    ));

    // Table Header
    const headerY = 150.0;
    const col1X = 100.0;
    const col2X = 400.0;
    const col3X = 650.0;
    const col4X = 900.0;

    container.add(TextComponent(
      text: 'Rule',
      textRenderer: GameStyles.label,
      position: Vector2(col1X, headerY),
      anchor: Anchor.centerLeft,
    ));
    container.add(TextComponent(
      text: 'Chips',
      textRenderer: GameStyles.label,
      position: Vector2(col2X, headerY),
      anchor: Anchor.center,
    ));
    container.add(TextComponent(
      text: 'Mult',
      textRenderer: GameStyles.label,
      position: Vector2(col3X, headerY),
      anchor: Anchor.center,
    ));
    container.add(TextComponent(
      text: 'Notes',
      textRenderer: GameStyles.label,
      position: Vector2(col4X, headerY),
      anchor: Anchor.centerLeft,
    ));

    // Table Rows
    final rules = [
      ('reit', '10', '0', 'Restatement'),
      ('&elim', '30', '2', 'And Elimination'),
      ('&intro', '20', '1', 'And Introduction'),
      ('~elim', '40', '2', 'Double Negation Elim'),
      ('~intro', '20', '1', 'Double Negation Intro'),
    ];

    for (int i = 0; i < rules.length; i++) {
      final y = 220.0 + i * 80.0;
      final rule = rules[i];

      container.add(TextComponent(
        text: rule.$1,
        textRenderer: GameStyles.valueSmall,
        position: Vector2(col1X, y),
        anchor: Anchor.centerLeft,
      ));
      container.add(TextComponent(
        text: '+${rule.$2}',
        textRenderer: GameStyles.valueSmall,
        position: Vector2(col2X, y),
        anchor: Anchor.center,
      )..scale = Vector2.all(0.8));
      container.add(TextComponent(
        text: 'x${rule.$3}',
        textRenderer: GameStyles.valueSmall,
        position: Vector2(col3X, y),
        anchor: Anchor.center,
      )..scale = Vector2.all(0.8));
      container.add(TextComponent(
        text: rule.$4,
        textRenderer: GameStyles.label,
        position: Vector2(col4X, y),
        anchor: Anchor.centerLeft,
      )..scale = Vector2.all(0.8));
    }

    // Close Button
    container.add(closeButton = GameButton(
      label: 'CLOSE',
      color: Colors.red.shade900,
      onPressed: () => runState.showRunInfo = false,
    )
      ..size = Vector2(200, 60)
      ..position = Vector2(containerSize.x / 2, containerSize.y - 80)
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
