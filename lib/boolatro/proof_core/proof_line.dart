/// A single proof line within a [ProofPath].
/// Holds the sentence, rule name, and optional raw citations payload.
class ProofLine {
  /// Sentence represented as a string (e.g., "P&Q", "~(A&B)").
  final String sentence;

  /// Rule name (e.g., "&intro", "reit").
  final String rule;

  /// Raw citations string (e.g., "2,3"), if provided separately.
  final String? citationsRaw;

  /// Creates a proof line with sentence and rule.
  const ProofLine({
    required this.sentence,
    required this.rule,
    this.citationsRaw,
  });
}
