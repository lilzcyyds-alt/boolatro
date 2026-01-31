import 'package:flutter/material.dart';
import '../state/proof_state.dart';
import '../state/run_state.dart';

class ProofEditor extends StatelessWidget {
  const ProofEditor({super.key, required this.runState});

  final RunState runState;

  @override
  Widget build(BuildContext context) {
    final ProofState proofState = runState.proofState;
    final String premise = proofState.premise ?? '';
    final resultMessage = proofState.lastValidationMessage;
    final resultValid = proofState.lastValidationPassed;
    final scoreDelta = proofState.lastScoreDelta;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'PROOF EDITOR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              IconButton(
                onPressed: runState.closeProofEditor,
                icon: const Icon(Icons.close, color: Colors.white70),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 16),
          Wrap(
            spacing: 16,
            children: [
              Text(
                'TARGET: ${proofState.blindTargetScore}',
                style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                'SCORE: ${proofState.blindScore}',
                style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                'HANDS: ${proofState.handsRemaining}',
                style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'LINE 1 (PREMISE): $premise',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...proofState.proofLines.map(
                    (line) => ProofLineRow(
                      key: ValueKey('proof-line-${line.id}'),
                      lineNumber: line.id + 1,
                      line: line,
                      onSentenceChanged: (value) =>
                          runState.updateProofLineSentence(line, value),
                      onRuleChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        runState.updateProofLineRule(line, value);
                      },
                      onCitationsChanged: (value) =>
                          runState.updateProofLineCitations(line, value),
                    ),
                  ),
                  if (proofState.proofLines.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'NO PROOF LINES YET',
                        style: TextStyle(color: Colors.white24, fontSize: 12, letterSpacing: 2),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: runState.addProofLine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                ),
                child: const Text('ADD LINE'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: runState.clearProofEditor,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white54,
                  side: const BorderSide(color: Colors.white24),
                ),
                child: const Text('CLEAR'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: (proofState.isFirstSubmissionInSession || proofState.handsRemaining > 0)
                    ? runState.submitProof
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: const Text('SUBMIT'),
              ),
            ],
          ),
          if (resultMessage != null && resultValid != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (resultValid ? Colors.green : Colors.red).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: (resultValid ? Colors.green : Colors.red).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${resultValid ? 'VALID' : 'INVALID'}: $resultMessage',
                    style: TextStyle(
                      color: resultValid ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  if (scoreDelta != null)
                    Text(
                      'Score +$scoreDelta',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ProofLineRow extends StatelessWidget {
  const ProofLineRow({
    required this.lineNumber,
    required this.line,
    required this.onSentenceChanged,
    required this.onRuleChanged,
    required this.onCitationsChanged,
    super.key,
  });

  final int lineNumber;
  final ProofLineDraft line;
  final ValueChanged<String> onSentenceChanged;
  final ValueChanged<String?> onRuleChanged;
  final ValueChanged<String> onCitationsChanged;

  static const List<String> _rules = <String>[
    'reit',
    '&elim',
    '&intro',
    '~elim',
    '~intro',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Line $lineNumber',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          TextFormField(
            key: ValueKey('proof-line-${line.id}-sentence'),
            initialValue: line.sentence,
            onChanged: onSentenceChanged,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              labelText: 'Sentence',
              labelStyle: TextStyle(color: Colors.white70, fontSize: 12),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: line.rule,
                    isDense: true,
                    dropdownColor: Colors.black87,
                    items: _rules
                        .map(
                          (rule) => DropdownMenuItem<String>(
                            value: rule,
                            child: Text(
                              rule,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onRuleChanged,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  key: ValueKey('proof-line-${line.id}-citations'),
                  initialValue: line.citations,
                  onChanged: onCitationsChanged,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    labelText: 'Citations',
                    labelStyle: TextStyle(color: Colors.white70, fontSize: 12),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
