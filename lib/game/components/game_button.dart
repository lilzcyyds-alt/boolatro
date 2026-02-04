import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle;
import '../boolatro_component.dart';
import '../styles.dart';

class GameButton extends BoolatroComponent with TapCallbacks {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final TextPaint? textRenderer;
  bool isEnabled = true;

  GameButton({
    required this.label,
    required this.color,
    required this.onPressed,
    this.textRenderer,
  });

  double _lastTapTime = 0;

  @override
  void onTapDown(TapDownEvent event) {
    if (isEnabled && isVisible) {
      final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
      if (now - _lastTapTime < 0.5) return; // Debounce 0.5s
      _lastTapTime = now;
      onPressed();
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(4),
    );
    
    // Shadow
    canvas.drawRRect(rect.shift(const Offset(2, 2)), Paint()..color = Colors.black.withOpacity(0.3));

    final paint = Paint()..color = isEnabled ? color : color.withOpacity(0.2);
    canvas.drawRRect(rect, paint);
    
    if (isEnabled) {
      canvas.drawRRect(rect, Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke);
    }

    final effectiveTextRenderer = textRenderer ?? (isEnabled ? GameStyles.label : TextPaint(style: GameStyles.label.style.copyWith(color: Colors.white24)));
    effectiveTextRenderer.render(
      canvas,
      label,
      Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
  }
}
