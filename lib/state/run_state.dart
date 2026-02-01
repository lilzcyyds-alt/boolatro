import 'dart:math';
import 'package:flutter/foundation.dart';

import '../boolatro/proof_core/play_card.dart';
import '../boolatro/proof_core/proof_line.dart';
import '../boolatro/proof_core/proof_path.dart';
import '../boolatro/proof_core/proof_validation_result.dart';
import '../boolatro/effects/effect_context.dart';
import '../boolatro/effects/effect_engine.dart';
import '../boolatro/effects/effect_trigger.dart';
import '../boolatro/proof_core/proof_scoring.dart';
import '../boolatro/proof_core/proof_validator.dart';
import '../game/components/logic_card.dart';
import '../game/game_config.dart';
import '../game/systems/blind_system.dart';
import 'proof_state.dart';
import 'shop_state.dart';

enum GamePhase {
  start,
  selectBlind,
  proof,
  cashout,
  shop,
  defeat,
}

class RunState extends ChangeNotifier {
  GamePhase _phase = GamePhase.start;
  double _elapsedSeconds = 0;
  double _lastDtSeconds = 0;
  final ProofState _proofState = ProofState();
  final ShopState _shopState = ShopState();
  final EffectEngine _effectEngine = const EffectEngine();

  int _currentAnte = 1;
  int _currentBlindIndex = 0; // 0: Small, 1: Big, 2: Boss

  int get currentAnte => _currentAnte;
  int get currentBlindIndex => _currentBlindIndex;

  GamePhase get phase => _phase;
  double get elapsedSeconds => _elapsedSeconds;
  double get lastDtSeconds => _lastDtSeconds;
  ProofState get proofState => _proofState;
  ShopState get shopState => _shopState;

  BlindConfig? _currentBlind;
  BlindConfig? get currentBlind => _currentBlind;

  void tick(double dtSeconds) {
    _lastDtSeconds = dtSeconds;
    _elapsedSeconds += dtSeconds;

    // We intentionally do NOT notifyListeners() every frame.
    // Phase logic and UI should be driven by discrete state changes.
  }

  bool _cashoutPending = false;

  void advancePhase() {
    final oldPhase = _phase;
    _phase = _nextPhase(_phase);

    if (oldPhase == GamePhase.start && _phase == GamePhase.selectBlind) {
      _shopState.seedDemoInventory();
    }

    if (_phase == GamePhase.proof) {
      _startBlind(resetBlind: true, config: _currentBlind);
    }
    if (_phase == GamePhase.cashout) {
      _cashoutPending = true;
    }
    if (_phase == GamePhase.shop) {
      // In Phase 4 we will drive shop entry triggers here.
      // For now, the UI reads from ShopState directly.
    }
    notifyListeners();
  }

  void selectBlind(BlindConfig config) {
    _currentBlind = config;
    notifyListeners();
  }

  void skipBlind() {
    if (_currentBlindIndex < 2) {
      _currentBlindIndex++;
      notifyListeners();
    }
  }

  void reset() {
    _phase = GamePhase.start;
    _elapsedSeconds = 0;
    _lastDtSeconds = 0;
    _shopState.money = GameConfig.initialMoney; // Reset money on game over/restart
    _shopState.owned.clear();
    _currentBlind = null;
    _currentAnte = 1;
    _currentBlindIndex = 0;
    _startBlind(resetBlind: true);
    notifyListeners();
  }

  void addConclusionCard(PlayCard card) {
    if (_proofState.editorOpen) return;
    _proofState.addConclusionCard(card);
    notifyListeners();
  }

  void reorderHand(int oldIndex, int newIndex) {
    if (_proofState.editorOpen) return;
    _proofState.reorderHand(oldIndex, newIndex);
    notifyListeners();
  }

  void reorderConclusionTokens(int oldIndex, int newIndex) {
    if (_proofState.editorOpen) return;
    _proofState.reorderConclusionTokens(oldIndex, newIndex);
    notifyListeners();
  }

  void removeLastConclusionCard() {
    if (_proofState.editorOpen) return;
    _proofState.removeLastConclusionCard();
    notifyListeners();
  }

  void removeConclusionCardAt(int index) {
    if (_proofState.editorOpen) return;
    _proofState.removeConclusionCardAt(index);
    notifyListeners();
  }

  void clearConclusion() {
    _proofState.clearConclusion();
    notifyListeners();
  }

  void discardHand() {
    if (_proofState.editorOpen) return;
    _proofState.discardHand();
    notifyListeners();
  }

  void openProofEditor() {
    if (_proofState.hasConclusion && _proofState.handsRemaining > 0) {
      _proofState.handsRemaining--;
      _proofState.editorOpen = true;

      // Always ensure we have a fresh conclusion line for this proof attempt
      // Remove any stale conclusion lines from previous attempts
      _proofState.proofLines.removeWhere((l) => l.isFixed);
      _proofState.addProofLine(
        isFixed: true,
        sentence: _proofState.conclusionText,
      );

      notifyListeners();
    }
  }

  void closeProofEditor() {
    _proofState.editorOpen = false;
    _proofState.conclusionTokens.clear(); // Clear the cards used in the conclusion
    _proofState.refillHand();
    _proofState.step = EditorStep.idle;
    _proofState.activeLineId = null;
    _proofState.pendingRule = null;
    _proofState.selectedSources.clear();

    if (_proofState.blindScore < _proofState.blindTargetScore &&
        _proofState.handsRemaining <= 0) {
      _phase = GamePhase.defeat;
    }

    notifyListeners();
  }

  void startAddLineFlow() {
    _proofState.activeLineId = null;
    _proofState.step = EditorStep.selectingRule;
    notifyListeners();
  }

  void startJustifyLineFlow(int lineId) {
    _proofState.activeLineId = lineId;
    _proofState.step = EditorStep.selectingRule;
    notifyListeners();
  }

  void selectRule(String rule) {
    _proofState.pendingRule = rule;
    _proofState.step = EditorStep.selectingSource;
    _proofState.selectedSources.clear();
    notifyListeners();
  }

  void pickFormulaSegment(String sentence, int sourceLineId) {
    final rule = _proofState.pendingRule;
    if (rule == null) return;

    _proofState.selectedSources.add((sentence, sourceLineId));

    // Determine if we have enough sources based on the rule
    bool isComplete = false;
    if (rule == '&intro') {
      if (_proofState.selectedSources.length == 2) {
        isComplete = true;
      }
    } else if (rule == '~elim') {
      // Check if source has double negation
      if (sentence.startsWith('~~')) {
        isComplete = true;
      }
    } else {
      // reit, &elim, ~intro only need 1 source
      isComplete = true;
    }

    if (isComplete) {
      // Calculate the resulting sentence based on the rule
      String newSentence = '';
      if (rule == '&intro') {
        final s1 = _proofState.selectedSources[0].$1;
        final s2 = _proofState.selectedSources[1].$1;
        newSentence = '($s1&$s2)';
      } else if (rule == '~intro') {
        final s = _proofState.selectedSources[0].$1;
        final hasConnective = s.contains('&') || s.contains('v');
        newSentence = hasConnective ? '~~($s)' : '~~$s';
      } else if (rule == '~elim') {
        final s = _proofState.selectedSources[0].$1;
        newSentence = s.startsWith('~~') ? s.substring(2) : s;
      } else {
        // reit, &elim
        newSentence = sentence;
      }

      final normalizedGenerated = ProofValidator.deepNormalizeParentheses(newSentence);
      final conclusionLine = _proofState.proofLines.firstWhere((l) => l.isFixed);
      final normalizedFixed = ProofValidator.deepNormalizeParentheses(conclusionLine.sentence);

      if (normalizedGenerated.toLowerCase() == normalizedFixed.toLowerCase()) {
        // MATCH! Update the fixed line and auto-submit.
        conclusionLine.rule = rule;
        conclusionLine.citations = _proofState.selectedSources.map((s) => s.$2).join(',');

        _proofState.step = EditorStep.idle;
        _proofState.pendingRule = null;
        _proofState.selectedSources.clear();
        _proofState.activeLineId = null;

        submitProof();
        return;
      }

      // If no match, we either add a new line or update an existing one (though justify is disabled now)
      final lineId = _proofState.activeLineId;
      final ProofLineDraft line;
      if (lineId != null) {
        line = _proofState.proofLines.firstWhere((l) => l.id == lineId);
        if (line.isFixed) {
           _proofState.setValidationResult(false, 'Cannot manually justify the conclusion. Use intermediate steps.');
           _proofState.step = EditorStep.idle;
           _proofState.pendingRule = null;
           _proofState.selectedSources.clear();
           _proofState.activeLineId = null;
           notifyListeners();
           return;
        }
      } else {
        line = _proofState.addProofLine();
      }

      line.sentence = newSentence;
      line.rule = rule;
      line.citations = _proofState.selectedSources.map((s) => s.$2).join(',');

      _proofState.step = EditorStep.idle;
      _proofState.pendingRule = null;
      _proofState.selectedSources.clear();
      _proofState.activeLineId = null;
    }
    
    notifyListeners();
  }

  void cancelGuidedFlow() {
    _proofState.step = EditorStep.idle;
    _proofState.pendingRule = null;
    _proofState.selectedSources.clear();
    notifyListeners();
  }

  void clearProofEditor() {
    _proofState.clearProofLines();
    _proofState.clearValidationResult();
    notifyListeners();
  }

  void updateProofLineSentence(ProofLineDraft line, String sentence) {
    line.sentence = sentence;
  }

  void updateProofLineRule(ProofLineDraft line, String rule) {
    line.rule = rule;
  }

  void updateProofLineCitations(ProofLineDraft line, String citations) {
    line.citations = citations;
  }

  ProofValidationResult submitProof() {
    final proofLines = _proofState.proofLines
        .map(
          (draft) => ProofLine(
            sentence: draft.sentence,
            rule: draft.rule,
            citationsRaw: draft.citations,
          ),
        )
        .toList();

    final proofPath = ProofPath(
      premise: _proofState.premise,
      conclusion: _proofState.conclusionText,
      proofLines: proofLines,
    );

    final result = ProofValidator.validateProofPath(proofPath);


    // Phase 3 settlement: valid / baseScore / fallbackScore.
    var delta = result.isValid
        ? ProofScoring.baseScore(proofPath)
        : ProofScoring.fallbackScore(proofPath, result);

    // Phase 4 baseline: apply owned SpecialCard effects.
    final patch = _effectEngine.computePatch(
      cards: _shopState.owned,
      ctx: EffectContext(
        trigger: EffectTrigger.onProofSubmitted,
        isProofValid: result.isValid,
        scoreDelta: delta,
        blindScore: _proofState.blindScore,
        blindTargetScore: _proofState.blindTargetScore,
        handsRemaining: _proofState.handsRemaining,
      ),
    );
    delta += patch.addScore;

    _proofState.blindScore += delta;
    _proofState.setValidationResult(
      result.isValid,
      result.message,
      scoreDelta: delta,
    );

    // Blind loop: clear -> Cashout, else check hands left.
    if (_proofState.blindScore >= _proofState.blindTargetScore) {
      _phase = GamePhase.cashout;
      _cashoutPending = true;

      // Logic for advancing sequence
      if (_currentBlindIndex == 2) {
        // Boss defeated
        _currentAnte++;
        _currentBlindIndex = 0;
      } else {
        _currentBlindIndex++;
      }
    } else {
    }

    closeProofEditor();
    return result;
  }

  void _startBlind({bool resetBlind = false, BlindConfig? config}) {
    if (resetBlind) {
      _proofState.blindScore = 0;
    }

    if (config != null) {
      _currentBlind = config;
      // Scale target score by ante
      _proofState.blindTargetScore = (config.targetScore * pow(1.5, _currentAnte - 1)).round();
      _proofState.handsRemaining = GameConfig.initialHands;
      _proofState.discardsRemaining = GameConfig.initialDiscards;
      
      _proofState.startNewTask(
        premise: config.premise,
      );
    } else {
      // Fallback or generator
      _proofState.resetToGlobalDefaults(ante: _currentAnte);
      _proofState.startNewTask();
    }

    // Clear the global position cache to prevent stale component inheritance
    LogicCardComponent.clearCache();

    // Round-start triggers.
    final patch = _effectEngine.computePatch(
      cards: _shopState.owned,
      ctx: EffectContext(
        trigger: EffectTrigger.onRoundStart,
        blindScore: _proofState.blindScore,
        blindTargetScore: _proofState.blindTargetScore,
        handsRemaining: _proofState.handsRemaining,
      ),
    );
    _proofState.handsRemaining += patch.addHands;
  }

  void buyCard(dynamic card) {
    if (_shopState.canBuy(card)) {
      _shopState.buy(card);
      notifyListeners();
    }
  }

  /// Apply cashout rewards once, then proceed to Shop.
  void cashOutAndGoToShop() {
    if (_phase != GamePhase.cashout) {
      return;
    }
    if (_cashoutPending) {
      // Use the reward from the current blind configuration
      _shopState.money += _currentBlind?.reward ?? 0;
      _cashoutPending = false;
    }
    _phase = GamePhase.shop;
    notifyListeners();
  }

  GamePhase _nextPhase(GamePhase phase) {
    switch (phase) {
      case GamePhase.start:
        return GamePhase.selectBlind;
      case GamePhase.selectBlind:
        return GamePhase.proof;
      case GamePhase.proof:
        return GamePhase.cashout;
      case GamePhase.cashout:
        return GamePhase.shop;
      case GamePhase.shop:
        if (_currentAnte > 8) {
          return GamePhase.start; // Win condition - could be a separate Victory phase
        }
        return GamePhase.selectBlind;
      case GamePhase.defeat:
        return GamePhase.start;
    }
  }
}
