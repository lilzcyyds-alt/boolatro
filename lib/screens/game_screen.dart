import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../state/proof_state.dart';
import '../state/run_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.enableTicker = true});

  final bool enableTicker;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final RunState _runState;
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _runState = RunState();
    if (widget.enableTicker) {
      _ticker = createTicker(_onTick)..start();
    }
  }

  void _onTick(Duration elapsed) {
    final Duration delta =
        _lastTick == Duration.zero ? Duration.zero : elapsed - _lastTick;
    _lastTick = elapsed;
    final double dtSeconds = delta.inMicroseconds / 1000000;
    _runState.tick(dtSeconds);
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _runState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      endDrawer: AnimatedBuilder(
        animation: _runState,
        builder: (context, child) {
          return _ProofDrawer(runState: _runState);
        },
      ),
      onEndDrawerChanged: (isOpen) {
        if (!isOpen) {
          _runState.closeProofEditor();
        }
      },
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _runState,
          builder: (context, child) {
            // Use Builder so the callback context is under this Scaffold.
            return Builder(
              builder: (scaffoldContext) {
                return Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
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
                          border: Border.all(color: Colors.white10),
                        ),
                        child: _GameLayout(
                          runState: _runState,
                          openProofDrawer: () {
                            Scaffold.of(scaffoldContext).openEndDrawer();
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _GameLayout extends StatelessWidget {
  const _GameLayout({
    required this.runState,
    required this.openProofDrawer,
  });

  final RunState runState;
  final VoidCallback openProofDrawer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HudBar(runState: runState),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _Stage(runState: runState),
          ),
        ),
        const SizedBox(height: 8),
        _BottomBar(runState: runState, openProofDrawer: openProofDrawer),
      ],
    );
  }
}

class _HudBar extends StatelessWidget {
  const _HudBar({required this.runState});

  final RunState runState;

  @override
  Widget build(BuildContext context) {
    final phase = runState.phase;
    final proof = runState.proofState;
    final shop = runState.shopState;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Text(
            _phaseLabel(phase),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white, letterSpacing: 1),
          ),
          const Spacer(),
          _HudPill(label: 'Money', value: '${shop.money}'),
          const SizedBox(width: 8),
          _HudPill(
            label: 'Blind',
            value: '${proof.blindScore}/${proof.blindTargetScore}',
          ),
          const SizedBox(width: 8),
          _HudPill(label: 'Hands', value: '${proof.handsRemaining}'),
        ],
      ),
    );
  }

  String _phaseLabel(GamePhase phase) {
    switch (phase) {
      case GamePhase.start:
        return 'START';
      case GamePhase.selectBlind:
        return 'SELECT BLIND';
      case GamePhase.proof:
        return 'PROOF';
      case GamePhase.cashout:
        return 'CASHOUT';
      case GamePhase.shop:
        return 'SHOP';
    }
  }
}

class _HudPill extends StatelessWidget {
  const _HudPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({required this.runState});

  final RunState runState;

  @override
  Widget build(BuildContext context) {
    switch (runState.phase) {
      case GamePhase.start:
        return _StartStage(runState: runState);
      case GamePhase.selectBlind:
        return _SelectBlindStage(runState: runState);
      case GamePhase.proof:
        return _ProofStage(runState: runState);
      case GamePhase.cashout:
        return _CashoutStage(runState: runState);
      case GamePhase.shop:
        return _ShopStage(runState: runState);
    }
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }
}

class _StartStage extends StatelessWidget {
  const _StartStage({required this.runState});

  final RunState runState;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _StageCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BOOLATRO',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Colors.white, letterSpacing: 2),
            ),
            const SizedBox(height: 12),
            const Text(
              'Logic-proof roguelike (prototype UI)',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: runState.advancePhase,
              child: const Text('Begin Run'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: runState.reset,
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectBlindStage extends StatelessWidget {
  const _SelectBlindStage({required this.runState});

  final RunState runState;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _StageCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Blind',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text(
              'Placeholder: one blind for now. Later: Small/Big/Boss cards.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: runState.advancePhase,
              child: const Text('Lock Blind'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProofStage extends StatelessWidget {
  const _ProofStage({required this.runState});

  final RunState runState;

  @override
  Widget build(BuildContext context) {
    final proof = runState.proofState;
    final premise = proof.premise ?? '...';
    final conclusion = proof.conclusionText;

    return Row(
      children: [
        Expanded(
          child: _StageCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premise',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Premise: $premise',
                  key: const Key('proof-premise'),
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Text(
                  'Conclusion',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Conclusion: ${conclusion.isEmpty ? '—' : conclusion}',
                  key: const Key('proof-conclusion'),
                  style: const TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                const Text(
                  'Edit proof in the right drawer →',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CashoutStage extends StatelessWidget {
  const _CashoutStage({required this.runState});

  final RunState runState;

  @override
  Widget build(BuildContext context) {
    final proof = runState.proofState;
    return Center(
      child: _StageCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cashout',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Blind score: ${proof.blindScore}/${proof.blindTargetScore}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: runState.cashOutAndGoToShop,
              child: const Text('Go to Shop'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopStage extends StatelessWidget {
  const _ShopStage({required this.runState});

  final RunState runState;

  @override
  Widget build(BuildContext context) {
    final shop = runState.shopState;

    return _StageCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Money: ${shop.money}  |  Owned: ${shop.owned.length}/${shop.inventoryLimit}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          const Text('Inventory', style: TextStyle(color: Colors.white70)),
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
          const Text('Owned', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          if (shop.owned.isEmpty)
            const Text('None', style: TextStyle(color: Colors.white54))
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
          const Spacer(),
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
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.runState, required this.openProofDrawer});

  final RunState runState;
  final VoidCallback openProofDrawer;

  @override
  Widget build(BuildContext context) {
    if (runState.phase != GamePhase.proof) {
      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          border: const Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          children: [
            const Spacer(),
            Text(
              'dt ${runState.lastDtSeconds.toStringAsFixed(3)}s',
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    final proof = runState.proofState;

    return Container(
      height: 128,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final card in proof.hand) ...[
                  OutlinedButton(
                    key: ValueKey('hand-card-${card.content}'),
                    onPressed: () => runState.addConclusionCard(card),
                    child: Text(card.content),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              OutlinedButton(
                onPressed:
                    proof.hasConclusion ? runState.removeLastConclusionCard : null,
                child: const Text('Backspace'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: proof.hasConclusion ? runState.clearConclusion : null,
                child: const Text('Clear'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                key: const Key('enter-proof-editor'),
                onPressed: proof.hasConclusion
                    ? () {
                        runState.openProofEditor();
                        openProofDrawer();
                      }
                    : null,
                child: const Text('Edit Proof'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProofDrawer extends StatelessWidget {
  const _ProofDrawer({required this.runState});

  final RunState runState;

  @override
  Widget build(BuildContext context) {
    final proof = runState.proofState;

    return SizedBox(
      width: 420,
      child: Drawer(
        backgroundColor: const Color(0xFF0E0E0E),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: proof.editorOpen
                ? _ProofEditor(runState: runState)
                : const Text(
                    'Build a conclusion first, then open the proof editor.',
                    style: TextStyle(color: Colors.white70),
                  ),
          ),
        ),
      ),
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
        Row(
          children: [
            Expanded(
              child: Text(
                'Proof Editor',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close, color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            Text(
              'Target: ${proofState.blindTargetScore}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Score: ${proofState.blindScore}',
              style: const TextStyle(color: Colors.white70),
            ),
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
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...proofState.proofLines.map(
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
                ),
                if (proofState.proofLines.isEmpty)
                  const Text(
                    'No proof lines yet. Add a line to begin.',
                    style: TextStyle(color: Colors.white54),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              key: const Key('proof-add-line'),
              onPressed: runState.addProofLine,
              child: const Text('Add Line'),
            ),
            OutlinedButton(
              onPressed: runState.clearProofEditor,
              child: const Text('Clear'),
            ),
            ElevatedButton(
              key: const Key('proof-submit'),
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
