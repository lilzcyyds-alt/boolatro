import 'proof_path.dart';
import 'proof_validation_result.dart';

/// Very early scoring model.
///
/// We keep this intentionally simple and deterministic so Phase 3 UI/gameplay
/// can be playable before we port the full Unity scoring system.
class ProofScoring {
  /// Score awarded when the proof is valid.
  static int baseScore(ProofPath path) {
    // Premise line is implicit in UI, so count only user lines.
    final int lines = path.proofLines.length;
    final int lengthBonus = (path.conclusion ?? '').trim().isEmpty ? 0 : 10;
    return 100 + (lines * 20) + lengthBonus;
  }

  /// Score awarded when the proof is invalid.
  ///
  /// This is the "fallback" scoring channel so players still get *something*
  /// for partial work, which makes the blind loop feel less binary.
  static int fallbackScore(ProofPath path, ProofValidationResult result) {
    // If they didn't even write anything, no pity points.
    if (path.proofLines.isEmpty) {
      return 0;
    }

    // If the failure is clearly a format issue, give fewer points.
    final String msg = result.message.toLowerCase();
    final bool looksLikeWffFailure =
        msg.contains('wff') || msg.contains('well-formed') || msg.contains('formula');

    final int lines = path.proofLines.length;
    final int raw = looksLikeWffFailure ? (lines * 2) : (lines * 5);

    // Cap fallback so it never beats a valid clear.
    return raw.clamp(0, 30);
  }
}
