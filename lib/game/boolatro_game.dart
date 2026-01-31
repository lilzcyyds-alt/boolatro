import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../state/run_state.dart';
import 'components/root_layout.dart';

class BoolatroGame extends FlameGame {
  final RunState runState;

  BoolatroGame({required this.runState})
      : super(
          camera: CameraComponent.withFixedResolution(
            width: 1600,
            height: 900,
          )..viewfinder.anchor = Anchor.topLeft,
        );

  @override
  Color backgroundColor() => const Color(0xFF1A1A1A);

  @override
  Future<void> onLoad() async {
    final rootLayout = RootLayoutComponent()..size = Vector2(1600, 900);
    world.add(rootLayout);
  }

  @override
  void update(double dt) {
    super.update(dt);
    runState.tick(dt);
  }
}
