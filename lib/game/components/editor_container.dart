import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle;
import '../boolatro_component.dart';
import '../styles.dart';

class EditorContainerComponent extends BoolatroComponent {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(UIConfig.editorPanelWidth, UIConfig.editorPanelHeight);
    isVisible = false;
  }

  @override
  void render(Canvas canvas) {
    if (!isVisible) return;

    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(16),
    );
    
    // Background - semi-transparent dark
    canvas.drawRRect(rect, Paint()..color = Colors.black.withOpacity(0.85));
    
    // Border
    canvas.drawRRect(rect, Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3);
  }
}
