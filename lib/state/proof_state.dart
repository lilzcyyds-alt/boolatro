import '../boolatro/proof_core/play_card.dart';
import '../boolatro/proof_core/proof_task_generator.dart';

class ProofLineDraft {
  ProofLineDraft({
    required this.id,
    this.sentence = '',
    this.rule = 'reit',
    this.citations = '',
  });

  final int id;
  String sentence;
  String rule;
  String citations;
}

class ProofState {
  ProofState() {
    _hand = _defaultHand();
  }

  String? premise;
  final List<PlayCard> conclusionTokens = <PlayCard>[];
  final List<ProofLineDraft> proofLines = <ProofLineDraft>[];

  /// Blind loop state (Phase 3).
  int handsRemaining = 3;
  int blindTargetScore = 120;
  int blindScore = 0;

  bool editorOpen = false;
  String? lastValidationMessage;
  bool? lastValidationPassed;
  int? lastScoreDelta;

  late final List<PlayCard> _hand;
  int _nextLineId = 1;

  List<PlayCard> get hand => _hand;

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
    lastValidationMessage = null;
    lastValidationPassed = null;
    lastScoreDelta = null;

    _nextLineId = 1;
  }

  void addConclusionCard(PlayCard card) {
    conclusionTokens.add(card);
  }

  void removeLastConclusionCard() {
    if (conclusionTokens.isEmpty) {
      return;
    }
    conclusionTokens.removeLast();
  }

  void clearConclusion() {
    conclusionTokens.clear();
  }

  ProofLineDraft addProofLine() {
    final line = ProofLineDraft(id: _nextLineId++);
    proofLines.add(line);
    return line;
  }

  void clearProofLines() {
    proofLines.clear();
    _nextLineId = 1;
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
