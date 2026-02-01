import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../state/run_state.dart';
import 'components/root_layout.dart';
import 'components/logic_card.dart';

class BoolatroGame extends FlameGame {
  final RunState runState;

  BoolatroGame({required this.runState})
      : super(
          camera: CameraComponent.withFixedResolution(
            width: 1920,
            height: 1080,
          )..viewfinder.anchor = Anchor.topLeft,
        );

  @override
  Color backgroundColor() => const Color(0xFF1A1A1A);

  late final RootLayoutComponent rootLayout;

  @override
  Future<void> onLoad() async {
    LogicCardComponent.clearCache();
    rootLayout = RootLayoutComponent()..size = Vector2(1920, 1080);
    world.add(rootLayout);
  }

  @override
  void update(double dt) {
    super.update(dt);
    runState.tick(dt);
  }
}
