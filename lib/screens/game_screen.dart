import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../state/run_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final RunState _runState;
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _runState = RunState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final Duration delta = _lastTick == Duration.zero
        ? Duration.zero
        : elapsed - _lastTick;
    _lastTick = elapsed;
    final double dtSeconds = delta.inMicroseconds / 1000000;
    _runState.tick(dtSeconds);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _runState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _runState,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueGrey.shade900,
                          Colors.black,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'BOOLATRO',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                      ),
                    ),
                  ),
                ),
                _PhaseOverlay(
                  phase: _runState.phase,
                  elapsedSeconds: _runState.elapsedSeconds,
                  lastDtSeconds: _runState.lastDtSeconds,
                  onAdvance: _runState.advancePhase,
                  onReset: _runState.reset,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PhaseOverlay extends StatelessWidget {
  const _PhaseOverlay({
    required this.phase,
    required this.elapsedSeconds,
    required this.lastDtSeconds,
    required this.onAdvance,
    required this.onReset,
  });

  final GamePhase phase;
  final double elapsedSeconds;
  final double lastDtSeconds;
  final VoidCallback onAdvance;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final String title = _phaseTitle(phase);
    final String action = _phaseActionLabel(phase);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Elapsed: ${elapsedSeconds.toStringAsFixed(2)}s',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'dt: ${lastDtSeconds.toStringAsFixed(3)}s',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: onAdvance,
                  child: Text(action),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onReset,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _phaseTitle(GamePhase phase) {
    switch (phase) {
      case GamePhase.start:
        return 'Start';
      case GamePhase.selectBlind:
        return 'Select Blind';
      case GamePhase.proof:
        return 'Proof';
      case GamePhase.cashout:
        return 'Cashout';
      case GamePhase.shop:
        return 'Shop';
    }
  }

  String _phaseActionLabel(GamePhase phase) {
    switch (phase) {
      case GamePhase.start:
        return 'Begin Run';
      case GamePhase.selectBlind:
        return 'Lock Blind';
      case GamePhase.proof:
        return 'Resolve Proof';
      case GamePhase.cashout:
        return 'Cash Out';
      case GamePhase.shop:
        return 'Back to Blinds';
    }
  }
}
