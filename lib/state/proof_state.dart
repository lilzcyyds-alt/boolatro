import '../boolatro/proof_core/play_card.dart';
import '../boolatro/proof_core/proof_task_generator.dart';

enum EditorStep {
  idle,
  selectingRule,
  selectingSource,
}

class ProofLineDraft {
  ProofLineDraft({
    required this.id,
    this.sentence = '',
    this.rule = '',
    this.citations = '',
    this.isFixed = false,
  });

  final int id;
  String sentence;
  String rule;
  String citations;
  final bool isFixed;
}

class ProofState {
  ProofState() {
    _hand = _defaultHand().toList();
  }

  static const int maxHandSize = 9;

  String? premise;
  final List<PlayCard> conclusionTokens = <PlayCard>[];
  final List<ProofLineDraft> proofLines = <ProofLineDraft>[];

  /// Blind loop state (Phase 3).
  int handsRemaining = 3;
  int blindTargetScore = 120;
  int blindScore = 0;

  bool editorOpen = false;
  bool isFirstSubmissionInSession = true;
  String? lastValidationMessage;
  bool? lastValidationPassed;
  int? lastScoreDelta;

  // Guided flow state
  EditorStep step = EditorStep.idle;
  int? activeLineId;
  String? pendingRule;
  final List<(String, int)> selectedSources = [];

  late List<PlayCard> _hand;
  int _nextLineId = 1;

  List<PlayCard> get hand => _hand;

  void refillHand() {
    final defaultCards = _defaultHand();
    int defaultIdx = 0;
    while (_hand.length < maxHandSize) {
      _hand.add(defaultCards[defaultIdx % defaultCards.length]);
      defaultIdx++;
    }
  }

  String get conclusionText =>
      conclusionTokens.map((card) => card.content).join();

  bool get hasConclusion => conclusionTokens.isNotEmpty;

  void startNewTask({
    CircuitLevel circuitLevel = CircuitLevel.one,
    Difficulty difficulty = Difficulty.small,
  }) {
    final (premiseSentence, _) =
        ProofTaskGenerator.generateTask(circuitLevel, difficulty);
    premise = premiseSentence;
    conclusionTokens.clear();
    proofLines.clear();

    // Reset per-attempt editor UI.
    editorOpen = false;
    isFirstSubmissionInSession = true;
    lastValidationMessage = null;
    lastValidationPassed = null;
    lastScoreDelta = null;

    step = EditorStep.idle;
    activeLineId = null;
    pendingRule = null;
    selectedSources.clear();

    _nextLineId = 1;
    refillHand();
  }

  void addConclusionCard(PlayCard card) {
    if (_hand.contains(card)) {
      _hand.remove(card);
      conclusionTokens.add(card);
    }
  }

  void removeLastConclusionCard() {
    if (conclusionTokens.isEmpty) {
      return;
    }
    final card = conclusionTokens.removeLast();
    _hand.add(card);
  }

  void clearConclusion() {
    _hand.addAll(conclusionTokens);
    conclusionTokens.clear();
  }

  ProofLineDraft addProofLine({bool isFixed = false, String sentence = ''}) {
    final line = ProofLineDraft(
      id: _nextLineId++,
      isFixed: isFixed,
      sentence: sentence,
    );

    if (isFixed) {
      proofLines.add(line);
    } else {
      // Insert before the first fixed line if it exists
      final fixedIndex = proofLines.indexWhere((l) => l.isFixed);
      if (fixedIndex != -1) {
        proofLines.insert(fixedIndex, line);
      } else {
        proofLines.add(line);
      }
    }
    return line;
  }

  void clearProofLines() {
    proofLines.removeWhere((l) => !l.isFixed);
    for (final line in proofLines) {
      if (line.isFixed) {
        line.rule = '';
        line.citations = '';
      }
    }
    // We don't necessarily need to reset _nextLineId to 1 if we keep lines, 
    // but we should ensure new IDs don't collide. 
    // Actually, fixed lines already have IDs. We can find the max ID + 1.
    if (proofLines.isEmpty) {
      _nextLineId = 1;
    } else {
      _nextLineId = proofLines.map((l) => l.id).reduce((a, b) => a > b ? a : b) + 1;
    }
  }

  void setValidationResult(bool isValid, String message, {int? scoreDelta}) {
    lastValidationPassed = isValid;
    lastValidationMessage = message;
    lastScoreDelta = scoreDelta;
  }

  void clearValidationResult() {
    lastValidationPassed = null;
    lastValidationMessage = null;
    lastScoreDelta = null;
  }

  static List<PlayCard> _defaultHand() {
    return const <PlayCard>[
      PlayCard(content: 'P', type: CardType.atom),
      PlayCard(content: 'Q', type: CardType.atom),
      PlayCard(content: 'R', type: CardType.atom),
      PlayCard(content: 'S', type: CardType.atom),
      PlayCard(content: 'T', type: CardType.atom),
      PlayCard(content: '~', type: CardType.connective),
      PlayCard(content: '&', type: CardType.connective),
      PlayCard(content: '(', type: CardType.connective),
      PlayCard(content: ')', type: CardType.connective),
    ];
  }
}
