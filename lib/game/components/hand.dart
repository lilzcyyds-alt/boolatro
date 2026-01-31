import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle;
import '../boolatro_component.dart';
import '../styles.dart';
import '../../state/run_state.dart';

class HandComponent extends BoolatroComponent {
  final List<LogicCardComponent> _cards = [];

  @override
  void onStateChanged() {
    if (!isLoaded) return;
    if (!isVisible) {
      _clearHand();
      return;
    }
    _refreshHand();
  }

  void _clearHand() {
    for (final card in _cards) {
      remove(card);
    }
    _cards.clear();
  }

  @override
  void render(Canvas canvas) {
    if (!isVisible || runState.phase == GamePhase.start) {
      _clearHand();
      return;
    }
    super.render(canvas);
  }

  void _refreshHand() {
    _clearHand();

    if (runState.phase != GamePhase.proof) return;

    final hand = runState.proofState.hand;
    final count = hand.length;
    if (count == 0) return;

    final cardWidth = 70.0;
    final cardHeight = 100.0;
    
    for (int i = 0; i < count; i++) {
      final double angle = (i - (count - 1) / 2) * 0.1;
      final double xOffset = (i - (count - 1) / 2) * 50;
      final double yOffset = (i - (count - 1) / 2).abs() * 10;

      final cardComp = LogicCardComponent(
        card: hand[i],
        onPressed: () => runState.addConclusionCard(hand[i]),
      )
        ..size = Vector2(cardWidth, cardHeight)
        ..position = Vector2(size.x / 2 + xOffset, size.y - 20 - yOffset)
        ..anchor = Anchor.bottomCenter
        ..angle = angle;
      
      add(cardComp);
      _cards.add(cardComp);
    }
  }
}

class LogicCardComponent extends PositionComponent with TapCallbacks {
  final dynamic card;
  final VoidCallback onPressed;

  LogicCardComponent({required this.card, required this.onPressed});

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
  }

  @override
  void render(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(8),
    );
    
    // Shadow
    canvas.drawRRect(
      rect.shift(const Offset(3, 3)),
      Paint()..color = Colors.black.withOpacity(0.4),
    );
    
    // Card body
    canvas.drawRRect(rect, Paint()..color = Colors.white);
    
    // Border
    canvas.drawRRect(rect, Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
    
    // Content text
    final textPainter = GameStyles.valueLarge;
    textPainter.render(
      canvas,
      card.content,
      Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
  }
}
