import 'dart:ui';
import 'package:flame/components.dart';
import '../state/run_state.dart';
import 'boolatro_game.dart';

abstract class BoolatroComponent extends PositionComponent with HasGameRef<BoolatroGame> {
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
