/// Result object for proof validation.
class ProofValidationResult {
  /// Whether the target (line/path) is valid.
  final bool isValid;

  /// Validation message (empty if valid).
  final String message;

  /// Creates a validation result with status and message.
  const ProofValidationResult(this.isValid, this.message);
}
