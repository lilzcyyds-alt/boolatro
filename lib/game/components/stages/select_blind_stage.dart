import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle, TextStyle, FontWeight;
import '../../boolatro_component.dart';
import '../../styles.dart';
// import '../../../state/run_state.dart';

class SelectBlindStageComponent extends BoolatroComponent {
  late final TextComponent titleText;
  late final BlindCardComponent blindCard;

  @override
  Future<void> onLoad() async {
    add(titleText = TextComponent(
      text: 'SELECT BLIND',
      textRenderer: GameStyles.title,
      anchor: Anchor.center,
    ));

    final cardWidth = 160.0;
    final cardHeight = 240.0;

    add(blindCard = BlindCardComponent(
      onPressed: () => runState.advancePhase(),
    )
      ..size = Vector2(cardWidth, cardHeight)
      ..anchor = Anchor.center);
    
    _layout();
  }

  @override
  void onStateChanged() {
    if (!isLoaded) return;
    _layout();
  }

  void _layout() {
    titleText.position = Vector2(size.x / 2, 60);
    blindCard.position = Vector2(size.x / 2, size.y / 2 + 20);
  }
}

class BlindCardComponent extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;

  BlindCardComponent({required this.onPressed});

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
  }

  @override
  void render(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(16),
    );
    
    // Outer glow/shadow
    canvas.drawRRect(
      rect.shift(const Offset(4, 4)),
      Paint()..color = Colors.black.withOpacity(0.5),
    );

    // Card background
    canvas.drawRRect(rect, Paint()..color = Colors.blue.shade900);
    
    // Border
    canvas.drawRRect(rect, Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4);
    
    // Title
    GameStyles.valueSmall.render(
      canvas,
      'SMALL BLIND',
      Vector2(size.x / 2, size.y / 2 - 20),
      anchor: Anchor.center,
    );

    // Reward
    GameStyles.label.render(
      canvas,
      'Reward: \$3',
      Vector2(size.x / 2, size.y / 2 + 20),
      anchor: Anchor.center,
    );

    // "Lock Blind" button appearance
    final btnRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.x / 2, size.y - 40), width: 120, height: 30),
      const Radius.circular(4),
    );
    canvas.drawRRect(btnRect, Paint()..color = Colors.white);
    
    final textPaint = TextPaint(style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12));
    textPaint.render(canvas, 'LOCK BLIND', Vector2(size.x / 2, size.y - 40), anchor: Anchor.center);
  }
}
