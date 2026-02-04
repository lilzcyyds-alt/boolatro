import 'inference_rule.dart';
import 'proof_path.dart';
import 'proof_validation_result.dart';

/// Very early scoring model.
///
/// We keep this intentionally simple and deterministic so Phase 3 UI/gameplay
/// can be playable before we port the full Unity scoring system.
class ProofScoring {
  /// Chips per card in conclusion.
  static const int chipsPerCard = 5;

  /// Calculate the score breakdown (chips and mult) for a proof attempt.
  static (int chips, int mult) calculateBreakdown(
    int cardCount,
    ProofPath path,
    bool isValid,
  ) {
    final int baseChips = cardCount * chipsPerCard;

    if (!isValid || path.proofLines.isEmpty) {
      return (baseChips, 1);
    }

    // Valid proof: add rule reward from the last line (conclusion line).
    final lastLine = path.proofLines.last;
    final reward = InferenceRuleRewards.getReward(lastLine.rule);

    return (baseChips + reward.ruleChips, 1 + reward.ruleMult);
  }
}
