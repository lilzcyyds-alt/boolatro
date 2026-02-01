import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle;
import '../boolatro_component.dart';
import '../styles.dart';
import '../../state/run_state.dart';

class PhaseInfoComponent extends BoolatroComponent {
  late final TextComponent phaseLabel;
  late final TextComponent phaseValue;

  @override
  Future<void> onLoad() async {
    add(phaseLabel = TextComponent(
      text: 'PHASE',
      textRenderer: GameStyles.label,
      position: Vector2(size.x / 2, 25),
      anchor: Anchor.center,
    ));

    add(phaseValue = TextComponent(
      text: '',
      textRenderer: GameStyles.valueSmall,
      position: Vector2(size.x / 2, 65),
      anchor: Anchor.center,
    ));

    onStateChanged();
  }

  @override
  void render(Canvas canvas) {
    if (!isVisible || runState.phase == GamePhase.start) return;

    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(8),
    );

    canvas.drawRRect(rect, Paint()..color = Colors.black.withOpacity(0.4));
    canvas.drawRRect(rect, Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
  }

  @override
  void onStateChanged() {
    if (!isLoaded || !isVisible || runState.phase == GamePhase.start) return;
    
    phaseValue.text = runState.phase.name.toUpperCase();
  }
}
