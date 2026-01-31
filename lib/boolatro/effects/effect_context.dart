import 'effect_trigger.dart';

/// A lightweight context bag for effect evaluation.
///
/// Keep this pure Dart (no Flutter deps) so we can unit test effects.
class EffectContext {
  EffectContext({
    required this.trigger,
    this.isProofValid,
    this.scoreDelta,
    this.blindScore,
    this.blindTargetScore,
    this.handsRemaining,
  });

  final EffectTrigger trigger;

  // Proof-related.
  final bool? isProofValid;
  final int? scoreDelta;

  // Blind-related.
  final int? blindScore;
  final int? blindTargetScore;
  final int? handsRemaining;
}
