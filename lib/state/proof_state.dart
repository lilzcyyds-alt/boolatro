import 'dart:math';

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
    _hand = [];
    refillHand();
  }

  static const int maxHandSize = 6;

  String? premise;
  final List<PlayCard> conclusionTokens = <PlayCard>[];
  final List<ProofLineDraft> proofLines = <ProofLineDraft>[];

  /// Blind loop state (Phase 3).
  int handsRemaining = 3;
  int blindTargetScore = 120;
  int blindScore = 0;
  int discardsRemaining = 3;

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
  int _nextCardId = 1;
  final Random _rng = Random();

  List<PlayCard> get hand => _hand;

  void refillHand() {
    final currentTotal = _hand.length + conclusionTokens.length;
    if (currentTotal < maxHandSize) {
      _drawCards(maxHandSize - currentTotal);
    }
  }

  void discardHand() {
    if (discardsRemaining <= 0) return;
    final count = _hand.length;
    if (count == 0) return;

    discardsRemaining--;
    _hand.clear();
    _drawCards(count);
  }

  void _drawCards(int count) {
    final templates = _defaultHandTemplates();
    for (int i = 0; i < count; i++) {
      final template = templates[_rng.nextInt(templates.length)];
      _hand.add(PlayCard(
        id: _nextCardId++,
        content: template.content,
        type: template.type,
      ));
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
    _nextCardId = 1;
    _hand.clear();
    refillHand();
  }

  void addConclusionCard(PlayCard card) {
    if (_hand.contains(card)) {
      _hand.remove(card);
      conclusionTokens.add(card);
    }
  }

  void reorderHand(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _hand.length) return;
    if (newIndex < 0 || newIndex >= _hand.length) return;
    final card = _hand.removeAt(oldIndex);
    _hand.insert(newIndex, card);
  }

  void reorderConclusionTokens(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= conclusionTokens.length) return;
    if (newIndex < 0 || newIndex >= conclusionTokens.length) return;
    final card = conclusionTokens.removeAt(oldIndex);
    conclusionTokens.insert(newIndex, card);
  }

  void removeLastConclusionCard() {
    if (conclusionTokens.isEmpty) {
      return;
    }
    final card = conclusionTokens.removeLast();
    _hand.add(card);
  }

  void removeConclusionCardAt(int index) {
    if (index < 0 || index >= conclusionTokens.length) return;
    final card = conclusionTokens.removeAt(index);
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

  static List<PlayCard> _defaultHandTemplates() {
    return <PlayCard>[
      PlayCard(id: 0, content: 'P', type: CardType.atom),
      PlayCard(id: 0, content: 'Q', type: CardType.atom),
      PlayCard(id: 0, content: 'R', type: CardType.atom),
      PlayCard(id: 0, content: 'S', type: CardType.atom),
      PlayCard(id: 0, content: 'T', type: CardType.atom),
      PlayCard(id: 0, content: '~', type: CardType.connective),
      PlayCard(id: 0, content: '&', type: CardType.connective),
      PlayCard(id: 0, content: '(', type: CardType.connective),
      PlayCard(id: 0, content: ')', type: CardType.connective),
    ];
  }
}
