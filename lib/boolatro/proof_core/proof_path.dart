import 'proof_line.dart';

/// The full proof process for a single path, from premise to conclusion.
class ProofPath {
  /// Ordered list of proof lines (user-authored or generated entries).
  final List<ProofLine> proofLines;

  /// Premise sentence (optional).
  final String? premise;

  /// Conclusion sentence (optional).
  final String? conclusion;

  /// Creates a path with optional premise/conclusion.
  ProofPath({
    this.premise,
    this.conclusion,
    List<ProofLine>? proofLines,
  }) : proofLines = proofLines ?? <ProofLine>[];
}
