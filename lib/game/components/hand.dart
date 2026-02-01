import 'dart:math' as math;
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
import 'logic_card.dart';

class HandComponent extends BoolatroComponent {
  final Map<int, LogicCardComponent> cardMap = {};
  final Set<int> _discardingIds = {};

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
      for (final card in cardMap.values) {
        card.isVisible = false;
      }
      return;
    }

    final hand = runState.proofState.hand;
    
    final ownedIds = hand.map((c) => c.id).toSet();
    
    // Identify cards to fly out
    for (final id in cardMap.keys.toList()) {
      if (!ownedIds.contains(id) && !_discardingIds.contains(id)) {
        final comp = cardMap[id]!;
        
        // Skip off-screen flyout if it's explicitly moving to conclusion
        final inConclusion = runState.proofState.conclusionTokens.any((c) => c.id == id);
        if (inConclusion) {
          cardMap.remove(id);
          remove(comp);
          continue;
        }

        _discardingIds.add(id);
        
        // Fly to random offscreen pos then remove
        comp.flyTo(LogicCardComponent.getRandomOffscreenPosition(size), duration: 0.6).then((_) {
          cardMap.remove(id);
          _discardingIds.remove(id);
          remove(comp);
        });
      }
    }

    final count = hand.length;
    if (count == 0) return;

    final cardWidth = 105.0;
    final cardHeight = 150.0;
    
    // Fanning logic based on UI doc
    for (int i = 0; i < count; i++) {
      final card = hand[i];
      final id = card.id;
      
      final double angle = 0;
      final double xOffset = (i - (count - 1) / 2) * 140; // Increased spacing to 140
      final double yOffset = 0;
      final targetPos = Vector2(size.x / 2 + xOffset, size.y / 2);

      var cardComp = cardMap[id];
      if (cardComp == null) {
        cardComp = LogicCardComponent(
          card: card,
          onPressed: () => runState.addConclusionCard(card),
        )
          ..size = Vector2(cardWidth, cardHeight)
          ..anchor = Anchor.center;
          
        // Use Global Registry for inheritance
        final cachedPos = LogicCardComponent.getCachedPosition(id);
        if (cachedPos != null) {
          cardComp.position = cachedPos - absolutePosition;
        } else {
          cardComp.position = LogicCardComponent.getRandomOffscreenPosition(size);
        }
        
        add(cardComp);
        cardMap[id] = cardComp;
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
    int newIdx = (relativeX / 140 + (hand.length - 1) / 2).round();
    newIdx = newIdx.clamp(0, hand.length - 1);

    if (newIdx != currentIdx) {
      runState.reorderHand(currentIdx, newIdx);
    }
  }
}
