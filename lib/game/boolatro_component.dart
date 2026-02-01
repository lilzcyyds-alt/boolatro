import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import '../state/run_state.dart';
import 'boolatro_game.dart';

mixin Flyable on PositionComponent {
  bool isFlying = false;

  Future<void> flyTo(
    Vector2 targetPosition, {
    double duration = 0.5,
    Curve curve = Curves.easeOutCubic,
    bool? isVisibleBefore,
    bool? isVisibleAfter,
  }) async {
    isFlying = true;
    if (isVisibleBefore != null && this is BoolatroComponent) {
      (this as BoolatroComponent).isVisible = isVisibleBefore;
    }

    // Remove any existing MoveEffects to avoid conflicts
    children.whereType<MoveEffect>().forEach((e) => e.removeFromParent());

    final effect = MoveEffect.to(
      targetPosition,
      EffectController(duration: duration, curve: curve),
    );
    await add(effect);
    await effect.completed;
    isFlying = false;

    if (isVisibleAfter != null && this is BoolatroComponent) {
      (this as BoolatroComponent).isVisible = isVisibleAfter;
    }
  }
}

abstract class BoolatroComponent extends PositionComponent with HasGameRef<BoolatroGame>, Flyable {
  RunState get runState => gameRef.runState;

  bool isVisible = true;

  /// Recursively checks if this component and all its parents are visible.
  bool get isEffectivelyVisible {
    if (!isVisible) return false;
    Component? p = parent;
    while (p != null) {
      if (p is BoolatroComponent && !p.isVisible) return false;
      p = p.parent;
    }
    return true;
  }

  @override
  bool containsLocalPoint(Vector2 point) => isEffectivelyVisible && super.containsLocalPoint(point);

  @override
  void renderTree(Canvas canvas) {
    if (isVisible) {
      super.renderTree(canvas);
    }
  }

  @override
  void onMount() {
    super.onMount();
    // Base component does NOT listen by default to avoid redundant updates.
    // Subclasses like StageComponent and RootLayout will manually subscribe.
  }

  @override
  void onRemove() {
    super.onRemove();
  }

  void onStateChanged() {
    // Override this to respond to state changes (manually subscribed)
  }
}

class BoolatroTextComponent extends TextComponent with Flyable {
  bool isVisible = true;

  @override
  bool containsLocalPoint(Vector2 point) => isVisible && super.containsLocalPoint(point);

  @override
  void renderTree(Canvas canvas) {
    if (isVisible) {
      super.renderTree(canvas);
    }
  }

  BoolatroTextComponent({
    super.text,
    super.textRenderer,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  });
}
