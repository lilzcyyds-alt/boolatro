import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/boolatro_game.dart';
import '../state/run_state.dart';
import '../widgets/proof_editor.dart';



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
            return ListenableBuilder(
              listenable: runState,
              builder: (context, _) {
                if (!runState.proofState.editorOpen) {
                  return const SizedBox.shrink();
                }
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: ProofEditor(runState: runState),
                  ),
                );
              },
            );
          },
        },
        initialActiveOverlays: const ['ProofEditor'],
      ),
    );
  }
}

