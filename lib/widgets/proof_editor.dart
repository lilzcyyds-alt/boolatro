import 'package:flutter/material.dart';
import '../state/proof_state.dart';
import '../state/run_state.dart';
import 'formula_view.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.transparent,
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
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
              IconButton(
                onPressed: runState.closeProofEditor,
                icon: const Icon(Icons.close, color: Colors.white70, size: 32),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 32, thickness: 2),
          Wrap(
            spacing: 32,
            runSpacing: 16,
            children: [
              Text(
                'TARGET: ${proofState.blindTargetScore}',
                style: const TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'SCORE: ${proofState.blindScore}',
                style: const TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'HANDS: ${proofState.handsRemaining}',
                style: const TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                   // Premise Row
                   _LineItem(
                     key: const Key('proof-premise-row'),
                     label: 'L1 (Premise)',
                     sentence: premise,
                     isInteractive: proofState.step == EditorStep.selectingSource,
                     ruleContext: proofState.pendingRule,
                     onPressed: (seg) => runState.pickFormulaSegment(seg, 1),
                     textKey: const Key('proof-premise'),
                   ),
                   const Divider(color: Colors.white12),
                  ...proofState.proofLines.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final line = entry.value;
                      return _LineItem(
                        label: 'L${index + 2}',
                        sentence: line.sentence,
                        rule: line.rule,
                        citations: line.citations,
                        isInteractive: proofState.step == EditorStep.selectingSource,
                        ruleContext: proofState.pendingRule,
                        onPressed: (seg) => runState.pickFormulaSegment(seg, index + 2),
                        isFixed: line.isFixed,
                        onJustify: line.isFixed ? null : () => runState.startJustifyLineFlow(line.id), // No justify for fixed
                        activeLineId: proofState.activeLineId,
                        currentLineId: line.id,
                        isSourceable: !line.isFixed, // Conclusion cannot be a source
                      );
                    },
                  ),
                  if (proofState.proofLines.isEmpty && proofState.step == EditorStep.idle)
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
          const SizedBox(height: 24),
          if (proofState.step == EditorStep.idle)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ElevatedButton(
                  key: const Key('proof-add-line'),
                  onPressed: runState.startAddLineFlow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('ADD LINE'),
                ),
                OutlinedButton(
                  onPressed: runState.clearProofEditor,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white54,
                    side: const BorderSide(color: Colors.white24, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Text('CLEAR'),
                ),
                // Using a Container with width to simulate spacer in Wrap if needed, 
                // but usually Wrap is better left to flow.
                ElevatedButton(
                  key: const Key('proof-submit'),
                  onPressed: runState.submitProof,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('SUBMIT'),
                ),
              ],
            ),
          if (proofState.step == EditorStep.selectingRule)
             _RulePicker(
               onRuleSelected: runState.selectRule,
               onCancel: runState.cancelGuidedFlow,
             ),
          if (proofState.step == EditorStep.selectingSource)
             _SourceSelectionHeader(
               rule: proofState.pendingRule ?? '',
               selectedCount: proofState.selectedSources.length,
               onCancel: runState.cancelGuidedFlow,
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

class _LineItem extends StatelessWidget {
  const _LineItem({
    required this.label,
    required this.sentence,
    this.rule,
    this.citations,
    this.isInteractive = false,
    this.ruleContext,
    this.onPressed,
    this.textKey,
    this.isFixed = false,
    this.onJustify,
    this.activeLineId,
    this.currentLineId,
    this.isSourceable = true,
    super.key,
  });

  final String label;
  final String sentence;
  final String? rule;
  final String? citations;
  final bool isInteractive;
  final String? ruleContext;
  final Function(String)? onPressed;
  final Key? textKey;
  final bool isFixed;
  final VoidCallback? onJustify;
  final int? activeLineId;
  final int? currentLineId;
  final bool isSourceable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              children: [
                Text(label, style: const TextStyle(color: Colors.white38, fontSize: 18, fontWeight: FontWeight.bold)),
                if (isFixed && (rule == null || rule!.isEmpty)) ...[
                  const SizedBox(width: 8),
                  Text('CONCLUSION',
                      style: TextStyle(color: Colors.orange.shade300, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
                if (rule != null && rule!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(rule!.toUpperCase(), style: const TextStyle(color: Colors.blueAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
                if (citations != null && citations!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text('($citations)', style: const TextStyle(color: Colors.white24, fontSize: 18)),
                ],
                const Spacer(),
                if (onJustify != null && activeLineId == null)
                  TextButton(
                    onPressed: onJustify,
                    child: const Text('JUSTIFY',
                        style: TextStyle(color: Colors.blueAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                if (activeLineId != null && activeLineId == currentLineId)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blueAccent, width: 2),
                    ),
                    child: const Text('EDITING', style: TextStyle(color: Colors.blueAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
           const SizedBox(height: 4),
           FormulaView(
             sentence: sentence,
             isClickable: isInteractive && isSourceable,
             highlightSubFormulas: isInteractive && isSourceable,
             ruleContext: ruleContext,
             onSegmentPressed: onPressed,
             textKey: textKey,
           ),
        ],
      ),
    );
  }
}

class _RulePicker extends StatelessWidget {
  const _RulePicker({required this.onRuleSelected, required this.onCancel});

  final Function(String) onRuleSelected;
  final VoidCallback onCancel;

  static const List<String> _rules = ['reit', '&elim', '&intro', '~elim', '~intro'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('SELECT RULE', style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: onCancel,
                child: const Text('CANCEL', style: TextStyle(color: Colors.redAccent, fontSize: 18)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: _rules.map((rule) => ElevatedButton(
              onPressed: () => onRuleSelected(rule),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade900,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              child: Text(rule),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _SourceSelectionHeader extends StatelessWidget {
  const _SourceSelectionHeader({required this.rule, required this.selectedCount, required this.onCancel});

  final String rule;
  final int selectedCount;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    String msg = 'PICK SOURCE FOR $rule';
    if (rule == '&intro') {
      msg = selectedCount == 0 ? 'PICK FIRST CONJUNCT' : 'PICK SECOND CONJUNCT';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(msg, style: const TextStyle(color: Colors.blueAccent, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: onCancel,
            child: const Text('CANCEL', style: TextStyle(color: Colors.redAccent, fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
