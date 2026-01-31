import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle;
import '../boolatro_component.dart';
import '../../state/run_state.dart';
import '../../boolatro/effects/effects.dart';
import '../styles.dart';

class JokerRowComponent extends BoolatroComponent {
  final List<JokerCardComponent> _jokers = [];

  @override
  void onStateChanged() {
    if (!isLoaded) return;
    if (!isVisible) {
      _clearJokers();
      return;
    }
    _refreshJokers();
  }

  void _clearJokers() {
    for (final joker in _jokers) {
      remove(joker);
    }
    _jokers.clear();
  }

  @override
  void render(Canvas canvas) {
    if (!isVisible || runState.phase == GamePhase.start) {
      _clearJokers();
      return;
    }
    super.render(canvas);
  }

  void _refreshJokers() {
    _clearJokers();

    final owned = runState.shopState.owned;
    if (owned.isEmpty) {
      return;
    }

    final cardWidth = 60.0;
    final cardHeight = 75.0;
    final spacing = 8.0;
    
    double startX = (size.x - (owned.length * (cardWidth + spacing) - spacing)) / 2;

    for (int i = 0; i < owned.length; i++) {
      final card = owned[i];
      final joker = JokerCardComponent(card: card)
        ..size = Vector2(cardWidth, cardHeight)
        ..position = Vector2(startX + i * (cardWidth + spacing), (size.y - cardHeight) / 2);
      add(joker);
      _jokers.add(joker);
    }
  }
}

class JokerCardComponent extends PositionComponent {
  final SpecialCard card;

  JokerCardComponent({required this.card});

  late final TextComponent nameText;

  @override
  Future<void> onLoad() async {
    add(nameText = TextComponent(
      text: card.name,
      textRenderer: GameStyles.label,
      position: size / 2,
      anchor: Anchor.center,
      priority: 1,
    ));
  }

  @override
  void render(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(6),
    );
    canvas.drawRRect(rect, Paint()..color = Colors.white12);
    canvas.drawRRect(rect, Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
  }
}
