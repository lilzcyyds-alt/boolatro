import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../state/proof_state.dart';
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
                  runState: _runState,
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
  const _PhaseOverlay({required this.runState});

  final RunState runState;

  @override
  Widget build(BuildContext context) {
    final GamePhase phase = runState.phase;
    final String title = _phaseTitle(phase);
    final String action = _phaseActionLabel(phase);

    Widget content;
    if (phase == GamePhase.proof) {
      content = _ProofPhasePanel(runState: runState);
    } else if (phase == GamePhase.shop) {
      content = _ShopPhasePanel(runState: runState);
    } else if (phase == GamePhase.cashout) {
      content = _CashoutPhasePanel(runState: runState);
    } else {
      content = Column(
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
            'Elapsed: ${runState.elapsedSeconds.toStringAsFixed(2)}s',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'dt: ${runState.lastDtSeconds.toStringAsFixed(3)}s',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: runState.advancePhase,
                child: Text(action),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: runState.reset,
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      );
    }

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
        child: content,
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

class _ProofPhasePanel extends StatelessWidget {
  const _ProofPhasePanel({required this.runState});

  final RunState runState;

  @override
  Widget build(BuildContext context) {
    final ProofState proofState = runState.proofState;
    final String premise = proofState.premise ?? '...';
    final String conclusion = proofState.conclusionText;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Proof',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'Premise: $premise',
          key: const Key('proof-premise'),
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 6),
        Text(
          'Conclusion: ${conclusion.isEmpty ? '—' : conclusion}',
          key: const Key('proof-conclusion'),
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: proofState.hand
              .map(
                (card) => OutlinedButton(
                  key: ValueKey('hand-card-${card.content}'),
                  onPressed: () => runState.addConclusionCard(card),
                  child: Text(card.content),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton(
              onPressed: proofState.hasConclusion
                  ? runState.removeLastConclusionCard
                  : null,
              child: const Text('Backspace'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: proofState.hasConclusion
                  ? runState.clearConclusion
                  : null,
              child: const Text('Clear'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              key: const Key('enter-proof-editor'),
              onPressed:
                  proofState.hasConclusion ? runState.openProofEditor : null,
              child: const Text('Enter Proof Editor'),
            ),
          ],
        ),
        if (proofState.editorOpen) ...[
          const SizedBox(height: 16),
          _ProofEditor(runState: runState),
        ],
      ],
    );
  }
}

class _ProofEditor extends StatelessWidget {
  const _ProofEditor({required this.runState});

  final RunState runState;

  @override
  Widget build(BuildContext context) {
    final ProofState proofState = runState.proofState;
    final String premise = proofState.premise ?? '';
    final resultMessage = proofState.lastValidationMessage;
    final resultValid = proofState.lastValidationPassed;
    final scoreDelta = proofState.lastScoreDelta;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Proof Editor',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Target: ${proofState.blindTargetScore}  ',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Score: ${proofState.blindScore}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(width: 12),
            Text(
              'Hands: ${proofState.handsRemaining}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Line 1 (Premise): $premise',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 12),
        Column(
          children: proofState.proofLines
              .map(
                (line) => _ProofLineRow(
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
              )
              .toList(),
        ),
        if (proofState.proofLines.isEmpty)
          const Text(
            'No proof lines yet. Add a line to begin.',
            style: TextStyle(color: Colors.white54),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton(
              onPressed: runState.addProofLine,
              child: const Text('Add Line'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: runState.clearProofEditor,
              child: const Text('Clear'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: runState.submitProof,
              child: const Text('Submit'),
            ),
          ],
        ),
        if (resultMessage != null && resultValid != null) ...[
          const SizedBox(height: 12),
          Text(
            '${resultValid ? 'Valid' : 'Invalid'}: $resultMessage',
            key: const Key('proof-validation-result'),
            style: TextStyle(
              color: resultValid ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
          if (scoreDelta != null)
            Text(
              'Score +$scoreDelta  (Total ${proofState.blindScore}/${proofState.blindTargetScore})',
              style: const TextStyle(color: Colors.white70),
            ),
          if (proofState.blindScore >= proofState.blindTargetScore)
            const Text(
              'Blind cleared → entering Cashout',
              style: TextStyle(color: Colors.greenAccent),
            )
          else if (proofState.handsRemaining <= 0)
            const Text(
              'No hands remaining → forced Cashout (TODO: fail state)',
              style: TextStyle(color: Colors.orangeAccent),
            ),
        ],
      ],
    );
  }
}

class _CashoutPhasePanel extends StatelessWidget {
  const _CashoutPhasePanel({required this.runState});

  final RunState runState;

  @override
  Widget build(BuildContext context) {
    final proof = runState.proofState;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cashout',
          style:
              Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'Blind score: ${proof.blindScore}/${proof.blindTargetScore}',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: runState.cashOutAndGoToShop,
          child: const Text('Go to Shop'),
        ),
      ],
    );
  }
}

class _ShopPhasePanel extends StatelessWidget {
  const _ShopPhasePanel({required this.runState});

  final RunState runState;

  @override
  Widget build(BuildContext context) {
    final shop = runState.shopState;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shop',
          style:
              Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'Money: ${shop.money}  |  Owned: ${shop.owned.length}/${shop.inventoryLimit}',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 12),
        const Text(
          'Inventory',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 6),
        if (shop.inventory.isEmpty)
          const Text(
            'No items (demo inventory is seeded at round start).',
            style: TextStyle(color: Colors.white54),
          )
        else
          Column(
            children: shop.inventory
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${card.name}  (cost ${card.cost})',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: shop.canBuy(card)
                              ? () {
                                  shop.buy(card);
                                  runState.notifyListeners();
                                }
                              : null,
                          child: const Text('Buy'),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 12),
        const Text(
          'Owned',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 6),
        if (shop.owned.isEmpty)
          const Text(
            'None',
            style: TextStyle(color: Colors.white54),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: shop.owned
                .map(
                  (card) => Chip(
                    label: Text(card.name),
                    backgroundColor: Colors.white10,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton(
              onPressed: runState.advancePhase,
              child: const Text('Back to Blinds'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: runState.reset,
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProofLineRow extends StatelessWidget {
  const _ProofLineRow({
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
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Sentence',
              labelStyle: TextStyle(color: Colors.white70),
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
              DropdownButton<String>(
                value: line.rule,
                dropdownColor: Colors.black87,
                items: _rules
                    .map(
                      (rule) => DropdownMenuItem<String>(
                        value: rule,
                        child: Text(
                          rule,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onRuleChanged,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  key: ValueKey('proof-line-${line.id}-citations'),
                  initialValue: line.citations,
                  onChanged: onCitationsChanged,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Citations',
                    labelStyle: TextStyle(color: Colors.white70),
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
