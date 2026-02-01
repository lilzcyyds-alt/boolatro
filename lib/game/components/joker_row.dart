import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle;
import '../boolatro_component.dart';
import '../../state/run_state.dart';
import '../../boolatro/effects/effects.dart';
import '../styles.dart';

class JokerRowComponent extends BoolatroComponent {
  final Map<int, JokerCardComponent> _jokerMap = {};

  @override
  void onMount() {
    super.onMount();
    runState.addListener(onStateChanged);
    onStateChanged();
  }

  @override
  void onRemove() {
    runState.removeListener(onStateChanged);
    super.onRemove();
  }

  @override
  void onStateChanged() {
    if (!isLoaded) return;
    _refreshJokers();
  }

  @override
  void render(Canvas canvas) {
    if (runState.phase == GamePhase.start) {
      return;
    }
    super.render(canvas);
  }

  void _refreshJokers() {
    final isStartPhase = runState.phase == GamePhase.start;
    if (isStartPhase) {
      for (final joker in _jokerMap.values) {
        joker.isVisible = false;
      }
      return;
    }

    final owned = runState.shopState.owned;
    
    // Remove jokers that are no longer owned
    final ownedIds = owned.map((c) => c.hashCode).toSet();
    _jokerMap.removeWhere((id, component) {
      if (!ownedIds.contains(id)) {
        remove(component);
        return true;
      }
      return false;
    });

    if (owned.isEmpty) {
      return;
    }

    final cardWidth = 84.0;
    final cardHeight = 112.0;
    final spacing = 12.0;
    
    // Center in the 1420px wide row
    double startX = (size.x - (owned.length * (cardWidth + spacing) - spacing)) / 2;

    for (int i = 0; i < owned.length; i++) {
      final card = owned[i];
      final id = card.hashCode;
      
      final targetPos = Vector2(startX + i * (cardWidth + spacing), (size.y - cardHeight) / 2);
      
      var joker = _jokerMap[id];
      if (joker == null) {
        joker = JokerCardComponent(card: card)
          ..size = Vector2(cardWidth, cardHeight)
          ..position = targetPos; // Snap on initial creation
        add(joker);
        _jokerMap[id] = joker;
      } else {
        joker.isVisible = true;
        joker.flyTo(targetPos);
      }
    }
  }
}

class JokerCardComponent extends PositionComponent with Flyable {
  final SpecialCard card;

  JokerCardComponent({required this.card});

  late final TextComponent nameText;
  bool isVisible = true;

  @override
  void renderTree(Canvas canvas) {
    if (isVisible) {
      super.renderTree(canvas);
    }
  }

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
