import 'dart:math';
import 'dart:ui';

import '../boolatro/proof_core/play_card.dart';
import '../boolatro/proof_core/proof_task_generator.dart';
import '../game/game_config.dart';
import '../game/systems/card_system.dart';

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

  static int get maxHandSize => GameConfig.maxHandSize;

  String? premise;
  final List<PlayCard> conclusionTokens = <PlayCard>[];
  final List<ProofLineDraft> proofLines = <ProofLineDraft>[];

  /// Blind loop state (Phase 3).
  int handsRemaining = GameConfig.initialHands;
  int blindTargetScore = 120;
  int blindScore = 0;
  int discardsRemaining = GameConfig.initialDiscards;

  /// Current proof breakdown.
  int currentChips = 0;
  int currentMult = 1;

  bool editorOpen = false;
  Offset? initialEditorPos;
  String? lastValidationMessage;
  bool? lastValidationPassed;
  int? lastScoreDelta;
  bool sessionSubmitted = false;
  bool showingValidationPopup = false;
  bool isClosing = false;

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

  void resetToGlobalDefaults({int ante = 1}) {
    // Basic scaling: 120 * 1.5 ^ (ante - 1)
    blindTargetScore = (120 * pow(1.5, ante - 1)).round();
    handsRemaining = GameConfig.initialHands;
    discardsRemaining = GameConfig.initialDiscards;
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
      final config = CardSystem.findRandomByContent(template.content);
      
      _hand.add(PlayCard(
        id: _nextCardId++,
        content: template.content,
        type: template.type,
        imagePath: config?.imagePath,
      ));
    }
  }

  String get conclusionText =>
      conclusionTokens.map((card) => card.content).join();

  bool get hasConclusion => conclusionTokens.isNotEmpty;

  void startNewTask({
    CircuitLevel circuitLevel = CircuitLevel.one,
    Difficulty difficulty = Difficulty.small,
    String? premise,
  }) {
    if (premise != null) {
      this.premise = premise;
      conclusionTokens.clear();
    } else {
      final (premiseSentence, _) =
          ProofTaskGenerator.generateTask(circuitLevel, difficulty);
      this.premise = premiseSentence;
    }
    conclusionTokens.clear();
    proofLines.clear();

    // Reset per-attempt editor UI.
    editorOpen = false;
    lastValidationMessage = null;
    lastValidationPassed = null;
    lastScoreDelta = null;
    showingValidationPopup = false;
    isClosing = false;

    step = EditorStep.idle;
    activeLineId = null;
    pendingRule = null;
    selectedSources.clear();
    sessionSubmitted = false;

    _nextLineId = 1;
    // _nextCardId is NOT reset - use monotonically increasing IDs across blinds
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
    final templates = <PlayCard>[];
    
    // Add atoms from config
    for (final atom in GameConfig.allowedAtoms) {
      templates.add(PlayCard(id: 0, content: atom, type: CardType.atom));
    }
    
    // Add connectives
    templates.addAll([
      PlayCard(id: 0, content: '~', type: CardType.connective),
      PlayCard(id: 0, content: '&', type: CardType.connective),
      PlayCard(id: 0, content: '(', type: CardType.connective),
      PlayCard(id: 0, content: ')', type: CardType.connective),
    ]);
    
    return templates;
  }
}
