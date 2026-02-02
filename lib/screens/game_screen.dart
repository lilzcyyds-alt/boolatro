import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/boolatro_game.dart';
import '../game/styles.dart';
import '../state/run_state.dart';
import '../widgets/proof_editor.dart';
import '../widgets/debug_panel.dart';



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
            return LayoutBuilder(
              builder: (context, constraints) {
                return ListenableBuilder(
                  listenable: runState,
                  builder: (context, _) {
                    if (!runState.proofState.editorOpen) {
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

                    final initialVirtualPos = runState.proofState.initialEditorPos;
                    final targetX = offsetX + panelPos.x * scale;
                    final targetY = offsetY + panelPos.y * scale;

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
                                child: ProofEditor(runState: runState),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    final startX = offsetX + initialVirtualPos.dx * scale;
                    final startY = offsetY + initialVirtualPos.dy * scale;

                    return Stack(
                      children: [
                        TweenAnimationBuilder<Offset>(
                          tween: Tween<Offset>(
                            begin: Offset(startX, startY),
                            end: Offset(targetX, targetY),
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
                              child: ProofEditor(runState: runState),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
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

