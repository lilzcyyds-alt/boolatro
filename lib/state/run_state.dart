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
import 'proof_state.dart';
import 'shop_state.dart';

enum GamePhase {
  start,
  selectBlind,
  proof,
  cashout,
  shop,
}

class RunState extends ChangeNotifier {
  GamePhase _phase = GamePhase.start;
  double _elapsedSeconds = 0;
  double _lastDtSeconds = 0;
  final ProofState _proofState = ProofState();
  final ShopState _shopState = ShopState();
  final EffectEngine _effectEngine = const EffectEngine();

  GamePhase get phase => _phase;
  double get elapsedSeconds => _elapsedSeconds;
  double get lastDtSeconds => _lastDtSeconds;
  ProofState get proofState => _proofState;
  ShopState get shopState => _shopState;

  void tick(double dtSeconds) {
    _lastDtSeconds = dtSeconds;
    _elapsedSeconds += dtSeconds;

    // We intentionally do NOT notifyListeners() every frame.
    // Phase logic and UI should be driven by discrete state changes.
  }

  bool _cashoutPending = false;

  void advancePhase() {
    _phase = _nextPhase(_phase);
    if (_phase == GamePhase.proof) {
      _startBlind();
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

  void reset() {
    _phase = GamePhase.start;
    _elapsedSeconds = 0;
    _lastDtSeconds = 0;
    _startBlind(resetBlind: true);
    notifyListeners();
  }

  void addConclusionCard(PlayCard card) {
    _proofState.addConclusionCard(card);
    notifyListeners();
  }

  void removeLastConclusionCard() {
    _proofState.removeLastConclusionCard();
    notifyListeners();
  }

  void clearConclusion() {
    _proofState.clearConclusion();
    notifyListeners();
  }

  void openProofEditor() {
    if (_proofState.hasConclusion) {
      _proofState.editorOpen = true;
      notifyListeners();
    }
  }

  void closeProofEditor() {
    _proofState.editorOpen = false;
    notifyListeners();
  }

  void addProofLine() {
    _proofState.addProofLine();
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

    // Blind loop: clear -> Cashout, else consume a hand and keep playing.
    if (_proofState.blindScore >= _proofState.blindTargetScore) {
      _phase = GamePhase.cashout;
      _cashoutPending = true;
    } else {
      _proofState.handsRemaining = (_proofState.handsRemaining - 1).clamp(0, 99);
      if (_proofState.handsRemaining <= 0) {
        // TODO: handle fail state properly (lose/forced cashout). For now, exit.
        _phase = GamePhase.cashout;
        _cashoutPending = true;
      } else {
        // Decision 1A: Keep the same premise/conclusion; player can iterate in editor.
      }
    }

    notifyListeners();
    return result;
  }

  void _startBlind({bool resetBlind = false}) {
    // TODO: move blind config to SelectBlind + difficulty. For now: fixed.
    if (resetBlind) {
      _proofState.blindScore = 0;
    }
    _proofState.blindTargetScore = 120;
    _proofState.handsRemaining = 3;

    // Demo: seed shop inventory once per run start.
    _shopState.seedDemoInventory();

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

    _proofState.startNewTask();
  }

  /// Apply cashout rewards once, then proceed to Shop.
  void cashOutAndGoToShop() {
    if (_phase != GamePhase.cashout) {
      return;
    }
    if (_cashoutPending) {
      // TODO: replace with full cashout system.
      // For now: convert blindScore to money at a simple rate.
      _shopState.money += (_proofState.blindScore / 10).floor();
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
        return GamePhase.selectBlind;
    }
  }
}
