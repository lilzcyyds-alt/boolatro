import 'package:flutter/material.dart';
import '../state/run_state.dart';

class DebugPanel extends StatefulWidget {
  final RunState runState;

  const DebugPanel({super.key, required this.runState});

  @override
  State<DebugPanel> createState() => _DebugPanelState();
}

class _DebugPanelState extends State<DebugPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (!_isExpanded) {
      return Material(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _isExpanded = true),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.bug_report, color: Colors.white70, size: 20),
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: widget.runState,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PHASE: ${widget.runState.phase.name.toUpperCase()}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _isExpanded = false),
                    icon: const Icon(Icons.close, color: Colors.white70, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => widget.runState.advancePhase(),
                    child: const Text('ADVANCE'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => widget.runState.reset(),
                    child: const Text('RESET'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'MONEY: ${widget.runState.shopState.money}',
                style: const TextStyle(color: Colors.orange),
              ),
            ],
          ),
        );
      },
    );
  }
}
