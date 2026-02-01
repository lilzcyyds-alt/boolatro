import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle;
import '../boolatro_component.dart';
import '../styles.dart';
import '../../state/run_state.dart';
import '../../boolatro/proof_core/play_card.dart';

class HandComponent extends BoolatroComponent {
  final Map<int, LogicCardComponent> _cardMap = {};

  @override
  void onStateChanged() {
    if (!isLoaded) return;
    _refreshHand();
  }

  @override
  void render(Canvas canvas) {
    if (runState.phase == GamePhase.start) {
      return;
    }
    super.render(canvas);
  }

  void _refreshHand() {
    final isProofPhase = runState.phase == GamePhase.proof;
    
    if (!isProofPhase) {
      for (final card in _cardMap.values) {
        card.isVisible = false;
      }
      return;
    }

    final hand = runState.proofState.hand;
    
    final ownedIds = hand.map((c) => c.hashCode).toSet();
    _cardMap.removeWhere((id, component) {
      if (!ownedIds.contains(id)) {
        remove(component);
        return true;
      }
      return false;
    });

    final count = hand.length;
    if (count == 0) return;

    final cardWidth = 105.0;
    final cardHeight = 150.0;
    
    // Fanning logic based on UI doc
    for (int i = 0; i < count; i++) {
      final card = hand[i];
      final id = card.hashCode;
      
      final double angle = (i - (count - 1) / 2) * 0.1;
      final double xOffset = (i - (count - 1) / 2) * 85; // Slightly increased spacing
      final double yOffset = (i - (count - 1) / 2).abs() * 12;
      final targetPos = Vector2(size.x / 2 + xOffset, size.y - 10 - yOffset);

      var cardComp = _cardMap[id];
      if (cardComp == null) {
        cardComp = LogicCardComponent(
          card: card,
          onPressed: () => runState.addConclusionCard(card),
        )
          ..size = Vector2(cardWidth, cardHeight)
          ..anchor = Anchor.bottomCenter;
        
        // If we are in the middle of a phase transition (from RootLayout), 
        // don't fly the cards internally to avoid double-animation.
        // We can check if parent position is far from target, but simpler is to 
        // just check if this is a fresh layout.
        cardComp.position = targetPos;
        add(cardComp);
        _cardMap[id] = cardComp;
      } else {
        cardComp.isVisible = true;
        cardComp.flyTo(targetPos);
      }
      
      cardComp.angle = angle;
    }
  }
}

class LogicCardComponent extends PositionComponent with TapCallbacks, Flyable {
  final dynamic card;
  final VoidCallback onPressed;
  bool isVisible = true;

  LogicCardComponent({required this.card, required this.onPressed});

  @override
  void renderTree(Canvas canvas) {
    if (isVisible) {
      super.renderTree(canvas);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isVisible) {
      onPressed();
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(8),
    );
    
    // Shadow - deeper for better elevation
    canvas.drawRRect(
      rect.shift(const Offset(4, 4)),
      Paint()..color = Colors.black.withOpacity(0.5),
    );
    
    // Card body
    canvas.drawRRect(rect, Paint()..color = Colors.white);
    
    // Border - more pronounced
    canvas.drawRRect(rect, Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3);
    
    // Content text - style based on card type
    // We need to import play_card.dart to check CardType
    final textPainter = (card.type == CardType.atom)
        ? GameStyles.cardAtom 
        : GameStyles.cardConnective;

    textPainter.render(
      canvas,
      card.content,
      Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
  }
}
