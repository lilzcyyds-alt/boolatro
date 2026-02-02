import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/boolatro_game.dart';
import '../game/styles.dart';
import '../state/run_state.dart';
import '../widgets/proof_editor.dart';
import '../widgets/debug_panel.dart';

class _ProofEditorOverlay extends StatefulWidget {
  const _ProofEditorOverlay({required this.runState});

  final RunState runState;

  @override
  State<_ProofEditorOverlay> createState() => _ProofEditorOverlayState();
}

class _ProofEditorOverlayState extends State<_ProofEditorOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _flyOutController;
  late Animation<Offset> _flyOutAnimation;
  Offset? _currentPosition;
  Offset? _flyOutTarget;
  bool _hasFlyOutStarted = false;

  @override
  void initState() {
    super.initState();
    _flyOutController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _flyOutController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.runState.closeProofEditor();
        _hasFlyOutStarted = false;
      }
    });
  }

  @override
  void dispose() {
    _flyOutController.dispose();
    super.dispose();
  }

  Offset _getRandomOffscreenPosition(double screenWidth, double screenHeight) {
    final rand = math.Random();
    final double angle = rand.nextDouble() * 2 * math.pi;
    const double dist = 2500.0;
    return Offset(
      screenWidth / 2 + math.cos(angle) * dist,
      screenHeight / 2 + math.sin(angle) * dist,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListenableBuilder(
          listenable: widget.runState,
          builder: (context, _) {
            final proofState = widget.runState.proofState;

            if (!proofState.editorOpen) {
              return const SizedBox.shrink();
            }

            // Map virtual 1920x1080 to physical screen coordinates
            const virtualW = UIConfig.screenWidth;
            const virtualH = UIConfig.screenHeight;

            final scale = math.min(
              constraints.maxWidth / virtualW,
              constraints.maxHeight / virtualH,
            );

            final offsetX = (constraints.maxWidth - virtualW * scale) / 2;
            final offsetY = (constraints.maxHeight - virtualH * scale) / 2;

            final panelPos = UIConfig.editorPanelPos;
            final panelW = UIConfig.editorPanelWidth;
            final panelH = UIConfig.editorPanelHeight;

            final targetX = offsetX + panelPos.x * scale;
            final targetY = offsetY + panelPos.y * scale;
            final targetPos = Offset(targetX, targetY);

            // Handle fly-out animation
            if (proofState.isClosing && !_hasFlyOutStarted) {
              _hasFlyOutStarted = true;
              _currentPosition = targetPos;
              _flyOutTarget = _getRandomOffscreenPosition(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              _flyOutAnimation = Tween<Offset>(
                begin: _currentPosition,
                end: _flyOutTarget,
              ).animate(CurvedAnimation(
                parent: _flyOutController,
                curve: Curves.easeInCubic,
              ));
              _flyOutController.forward(from: 0);
            }

            // Fly-out animation in progress
            if (_hasFlyOutStarted) {
              return AnimatedBuilder(
                animation: _flyOutAnimation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        left: _flyOutAnimation.value.dx,
                        top: _flyOutAnimation.value.dy,
                        width: panelW * scale,
                        height: panelH * scale,
                        child: child!,
                      ),
                    ],
                  );
                },
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: panelW,
                    height: panelH,
                    child: ProofEditor(runState: widget.runState),
                  ),
                ),
              );
            }

            final initialVirtualPos = proofState.initialEditorPos;

            // No initial position - just show at target
            if (initialVirtualPos == null) {
              return Stack(
                children: [
                  Positioned(
                    left: targetX,
                    top: targetY,
                    width: panelW * scale,
                    height: panelH * scale,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: panelW,
                        height: panelH,
                        child: ProofEditor(runState: widget.runState),
                      ),
                    ),
                  ),
                ],
              );
            }

            // Fly-in animation
            final startX = offsetX + initialVirtualPos.dx * scale;
            final startY = offsetY + initialVirtualPos.dy * scale;

            return Stack(
              children: [
                TweenAnimationBuilder<Offset>(
                  tween: Tween<Offset>(
                    begin: Offset(startX, startY),
                    end: targetPos,
                  ),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (context, pos, child) {
                    return Positioned(
                      left: pos.dx,
                      top: pos.dy,
                      width: panelW * scale,
                      height: panelH * scale,
                      child: child!,
                    );
                  },
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: panelW,
                      height: panelH,
                      child: ProofEditor(runState: widget.runState),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}



class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.enableTicker = true});

  final bool enableTicker;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final RunState runState;

  late final BoolatroGame _game;

  @override
  void initState() {
    super.initState();
    runState = RunState();
    _game = BoolatroGame(runState: runState);
  }

  @override
  void dispose() {
    runState.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget(
        game: _game,
        overlayBuilderMap: {
          'ProofEditor': (context, BoolatroGame game) {
            return _ProofEditorOverlay(runState: runState);
          },
          'DebugPanel': (context, BoolatroGame game) {
            return Positioned(
              top: 10,
              right: 10,
              child: DebugPanel(runState: runState),
            );
          },
        },
        initialActiveOverlays: const ['ProofEditor', 'DebugPanel'],
      ),
    );
  }
}

