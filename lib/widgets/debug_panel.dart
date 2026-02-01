import 'package:flutter/material.dart';
import '../state/run_state.dart';

class DebugPanel extends StatelessWidget {
  final RunState runState;

  const DebugPanel({super.key, required this.runState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: runState,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PHASE: ${runState.phase.name.toUpperCase()}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => runState.advancePhase(),
                    child: const Text('ADVANCE'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => runState.reset(),
                    child: const Text('RESET'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'MONEY: ${runState.shopState.money}',
                style: const TextStyle(color: Colors.orange),
              ),
            ],
          ),
        );
      },
    );
  }
}
