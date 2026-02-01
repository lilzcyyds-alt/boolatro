import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle;
import '../boolatro_component.dart';
import '../styles.dart';
import '../../state/run_state.dart';
import '../../boolatro/proof_core/play_card.dart';
import '../boolatro_game.dart';
import 'stages/proof_stage.dart';

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
      
      final double angle = 0;
      final double xOffset = (i - (count - 1) / 2) * 110; // Fixed spacing for linear layout
      final double yOffset = 0;
      final targetPos = Vector2(size.x / 2 + xOffset, size.y / 2);

      var cardComp = _cardMap[id];
      if (cardComp == null) {
        cardComp = LogicCardComponent(
          card: card,
          onPressed: () => runState.addConclusionCard(card),
        )
          ..size = Vector2(cardWidth, cardHeight)
          ..anchor = Anchor.center
          ..position = targetPos;
        add(cardComp);
        _cardMap[id] = cardComp;
      }

      cardComp.isVisible = true;
      cardComp.targetPos = targetPos;
      cardComp.targetAngle = angle;
      
      // Only update priority and angle/pos if NOT dragging
      if (!cardComp.isDragging) {
        // Boost priority while flying back to avoid being covered
        cardComp.priority = 100;
        final targetComp = cardComp;
        targetComp.flyTo(targetPos).then((_) {
          // Reset priority only if we are not dragging/flying again
          if (targetComp.isLoaded && !targetComp.isDragging && !targetComp.isFlying) {
            targetComp.priority = i;
          }
        });
        cardComp.angle = angle;
      }
    }
  }

  void handleCardDropped(LogicCardComponent cardComp) {
    // We already have the card's position relative to its parent (this HandComponent)
    // because it's a child. So we can just use cardComp.position.
    final localPos = cardComp.position;
    
    // Check if dropped in stage area (Central Region)
    // Stage area is Region C: (250, 120) Size: (1420, 750) 
    // Hand is Region E: (250, 880) Size: (1420, 190)
    // hand.position is (250, 880) relative to RootLayout.
    // So localPos in hand: (0,0) is (250, 880) globally.
    // Stage is at (-760) relative to Hand (880 - 120 = 760).
    // Let's use Rects from UIConfig for safety if available or just hardcoded relative check.
    
    if (localPos.y < -100) {
      // Dropped above hand, likely stage area
      runState.addConclusionCard(cardComp.card);
      return;
    }

    // After drop, ensure it flies to its final position
    cardComp.flyTo(cardComp.targetPos);
  }

  void checkReorder(LogicCardComponent cardComp) {
    final localPos = cardComp.position;
    final hand = runState.proofState.hand;
    final currentIdx = hand.indexOf(cardComp.card);
    if (currentIdx == -1) return;

    // Calculate new index based on x position
    final double relativeX = localPos.x - size.x / 2;
    int newIdx = (relativeX / 110 + (hand.length - 1) / 2).round();
    newIdx = newIdx.clamp(0, hand.length - 1);

    if (newIdx != currentIdx) {
      runState.reorderHand(currentIdx, newIdx);
    }
  }
}

class LogicCardComponent extends PositionComponent with TapCallbacks, DragCallbacks, Flyable, HasGameRef<BoolatroGame> {
  final dynamic card;
  final VoidCallback onPressed;
  bool isVisible = true;
  bool isDragging = false;
  
  Vector2 targetPos = Vector2.zero();
  double targetAngle = 0;

  LogicCardComponent({required this.card, required this.onPressed});

  @override
  void renderTree(Canvas canvas) {
    if (isVisible) {
      super.renderTree(canvas);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Re-disabled click-to-play as requested to avoid conflicts
    // if (isVisible) onPressed();
  }

  @override
  void onDragStart(DragStartEvent event) {
    isDragging = true;
    priority = 1000; // Bring to front
    // scale = Vector2.all(1.1); // Visual feedback
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
    angle = 0; // Straighten when dragging
    
    final parent = this.parent;
    if (parent is HandComponent) {
      parent.checkReorder(this);
    } else if (parent is ProofStageComponent) {
      parent.checkReorder(this);
    }
    
    super.onDragUpdate(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    isDragging = false;
    // scale = Vector2.all(1.0);
    
    final parent = this.parent;
    if (parent is HandComponent) {
      parent.handleCardDropped(this);
    } else if (parent is ProofStageComponent) {
      // Handle drag back to hand
      parent.handleCardDroppedBack(this);
    }
    
    super.onDragEnd(event);
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
