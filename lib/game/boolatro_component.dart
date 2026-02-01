import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import '../state/run_state.dart';
import 'boolatro_game.dart';

mixin Flyable on PositionComponent {
  /// Smoothly moves the component to a target position.
  /// If [isVisibleAfter] is false, the component will be hidden after the animation completes.
  /// If [isVisibleBefore] is true, the component will be shown before the animation starts.
  Future<void> flyTo(
    Vector2 targetPosition, {
    double duration = 0.5,
    Curve curve = Curves.easeOutCubic,
    bool? isVisibleBefore,
    bool? isVisibleAfter,
  }) async {
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

    if (isVisibleAfter != null && this is BoolatroComponent) {
      (this as BoolatroComponent).isVisible = isVisibleAfter;
    }
  }
}

abstract class BoolatroComponent extends PositionComponent with HasGameRef<BoolatroGame>, Flyable {
  RunState get runState => gameRef.runState;

  bool isVisible = true;

  @override
  void renderTree(Canvas canvas) {
    if (isVisible) {
      super.renderTree(canvas);
    }
  }

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

  void onStateChanged() {
    // Override this to respond to state changes
  }
}

class BoolatroTextComponent extends TextComponent with Flyable {
  bool isVisible = true;

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
