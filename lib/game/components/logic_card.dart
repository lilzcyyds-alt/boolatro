import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle;
import '../boolatro_component.dart';
import '../styles.dart';
import '../boolatro_game.dart';
import '../../boolatro/proof_core/play_card.dart';
import 'hand.dart';
import 'stages/proof_stage.dart';

class LogicCardComponent extends PositionComponent with TapCallbacks, DragCallbacks, Flyable, HasGameRef<BoolatroGame> {
  final dynamic card;
  final VoidCallback onPressed;
  bool isVisible = true;
  bool isDragging = false;
  
  Vector2 targetPos = Vector2.zero();
  double targetAngle = 0;

  // Global Position Registry for seamless transitions
  static final Map<int, Vector2> _lastGlobalPositions = {};

  static void updateCache(int id, Vector2 globalPos) {
    _lastGlobalPositions[id] = globalPos;
  }

  static Vector2? getCachedPosition(int id) {
    return _lastGlobalPositions[id];
  }

  static void clearCache() {
    _lastGlobalPositions.clear();
  }

  static Vector2 getRandomOffscreenPosition(Vector2 size) {
    final rand = math.Random();
    final double angle = rand.nextDouble() * 2 * math.pi;
    final double dist = 2500.0; // Increased distance to ensure it's far beyond 1920x1080
    return Vector2(
      size.x / 2 + math.cos(angle) * dist,
      size.y / 2 + math.sin(angle) * dist,
    );
  }

  LogicCardComponent({required this.card, required this.onPressed});

  @override
  void update(double dt) {
    super.update(dt);
    if (isLoaded && !isFlying) {
      updateCache(card.id, absolutePosition);
    }
  }

  @override
  void renderTree(Canvas canvas) {
    if (isVisible) {
      super.renderTree(canvas);
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    isDragging = true;
    priority = 1000;
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
    angle = 0;
    
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
    
    final parent = this.parent;
    if (parent is HandComponent) {
      parent.handleCardDropped(this);
    } else if (parent is ProofStageComponent) {
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
    
    canvas.drawRRect(
      rect.shift(const Offset(4, 4)),
      Paint()..color = Colors.black.withOpacity(0.5),
    );
    
    canvas.drawRRect(rect, Paint()..color = Colors.white);
    
    canvas.drawRRect(rect, Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3);
    
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
