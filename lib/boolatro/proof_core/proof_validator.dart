import 'proof_line.dart';
import 'proof_path.dart';
import 'proof_validation_result.dart';

/// Proof validator responsible for validating logical proofs.
class ProofValidator {
  static final Set<String> _atomicSentences = {
    'A',
    'B',
    'C',
    'D',
    'E',
    'P',
    'Q',
    'R',
    'S',
    'T',
  };

  /// Public entry for WFF check.
  static bool isWellFormedFormula(String sentence) {
    return _isWff(sentence);
  }

  /// Validate a single proof line against the current proof path context.
  static ProofValidationResult validateProofLine(
    ProofLine proofLine,
    ProofPath proofPath,
    int lineNumber,
  ) {
    if (proofLine.rule.trim().isEmpty) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: A proof rule is required.',
      );
    }

    final sentence = proofLine.sentence.trim();
    if (sentence.isEmpty) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: A sentence is required.',
      );
    }

    if (!isWellFormedFormula(sentence)) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: The sentence is not a well-formed formula: "$sentence".',
      );
    }

    final parsed = _parseRuleAndCitations(proofLine.rule, proofLine.citationsRaw);
    final ruleName = parsed.$1;
    final citation = parsed.$2;

    switch (ruleName) {
      case 'reit':
        return _validateReit(sentence, citation, proofPath, lineNumber);
      case '&elim':
        return _validateAndElim(sentence, citation, proofPath, lineNumber);
      case '&intro':
        return _validateAndIntro(sentence, citation, proofPath, lineNumber);
      case '~elim':
        return _validateNegElim(sentence, citation, proofPath, lineNumber);
      case '~intro':
        return _validateNegIntro(sentence, citation, proofPath, lineNumber);
      default:
        return ProofValidationResult(
          false,
          'Unrecognized proof rule: "$ruleName".',
        );
    }
  }

  /// Validate the entire proof path (premise + all lines) in sequence.
  /// Also check that the last line of the proof matches the expected conclusion.
  static ProofValidationResult validateProofPath(ProofPath proofPath) {
    if (proofPath.proofLines.isEmpty) {
      return const ProofValidationResult(
        false,
        'Proof must have at least one line to reach a conclusion.',
      );
    }

    for (var i = 0; i < proofPath.proofLines.length; i++) {
      final result = validateProofLine(
        proofPath.proofLines[i],
        proofPath,
        i + 2,
      );
      if (!result.isValid) {
        return result;
      }
    }

    final conclusionResult = validateProofConclusionConsistency(proofPath);
    if (!conclusionResult.isValid) {
      return conclusionResult;
    }

    return const ProofValidationResult(true, 'Proof validation passed.');
  }

  /// Validate that the last line of the proof matches the expected conclusion.
  static ProofValidationResult validateProofConclusionConsistency(
    ProofPath proofPath,
  ) {
    if (proofPath.conclusion == null || proofPath.conclusion!.trim().isEmpty) {
      return const ProofValidationResult(
        false,
        'No target conclusion specified - cannot validate consistency.',
      );
    }

    if (proofPath.proofLines.isEmpty) {
      return const ProofValidationResult(
        false,
        'No proof lines present - cannot reach conclusion.',
      );
    }

    final lastProofLine = proofPath.proofLines.last;
    final lastLineContent = lastProofLine.sentence.trim();
    if (lastLineContent.isEmpty) {
      return const ProofValidationResult(
        false,
        'The last line of the proof is empty.',
      );
    }

    final normalizedLastLine = _deepNormalizeParentheses(lastLineContent);
    final normalizedConclusion = _deepNormalizeParentheses(
      proofPath.conclusion!.trim(),
    );

    if (normalizedLastLine.toLowerCase() != normalizedConclusion.toLowerCase()) {
      return ProofValidationResult(
        false,
        "Proof conclusion mismatch: Your proof ends with '$lastLineContent' but you need to prove '${proofPath.conclusion}'. The last line of your proof must exactly match your intended conclusion.",
      );
    }

    return const ProofValidationResult(true, 'Proof conclusion matches the target.');
  }

  static (String, String) _parseRuleAndCitations(
    String rule,
    String? citationsRaw,
  ) {
    final trimmedRule = rule.trim();
    if (citationsRaw != null && citationsRaw.trim().isNotEmpty) {
      return (trimmedRule.toLowerCase(), citationsRaw.trim());
    }

    final parts = trimmedRule.split(';');
    final ruleName = parts.first.trim().toLowerCase();
    final citation = parts.length > 1 ? parts[1].trim() : '';
    return (ruleName, citation);
  }

  /// Reiteration: the justified sentence must match the cited sentence exactly.
  static ProofValidationResult _validateReit(
    String sentence,
    String citation,
    ProofPath proofPath,
    int lineNumber,
  ) {
    if (citation.trim().isEmpty) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: Reit requires a cited line number.',
      );
    }

    final targetLine = int.tryParse(citation.trim());
    if (targetLine == null) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: Invalid cited line number.',
      );
    }

    final targetSentence = _getSentenceFromLine(targetLine, proofPath);
    if (targetSentence.isEmpty) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: Cited line $targetLine is empty.',
      );
    }

    final normalizedSentence = _deepNormalizeParentheses(sentence);
    final normalizedTarget = _deepNormalizeParentheses(targetSentence);

    if (normalizedSentence.toLowerCase() == normalizedTarget.toLowerCase()) {
      return const ProofValidationResult(true, '');
    }

    return ProofValidationResult(
      false,
      'Line $lineNumber: Reit requires the sentence to exactly match the cited sentence.',
    );
  }

  /// &Elim: the cited sentence must be a conjunction; the conclusion must be one of its conjuncts.
  static ProofValidationResult _validateAndElim(
    String sentence,
    String citation,
    ProofPath proofPath,
    int lineNumber,
  ) {
    if (citation.trim().isEmpty) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: &Elim requires a cited line number.',
      );
    }

    final targetLine = int.tryParse(citation.trim());
    if (targetLine == null) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: Invalid cited line number.',
      );
    }

    final targetSentence = _getSentenceFromLine(targetLine, proofPath);
    if (targetSentence.isEmpty) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: Cited line $targetLine is empty.',
      );
    }

    final mainConnective = _getMainConnective(targetSentence);
    if (mainConnective != '&') {
      return ProofValidationResult(
        false,
        'Line $lineNumber: &Elim requires the cited sentence to be a conjunction, but "$targetSentence" is not.',
      );
    }

    final conjuncts = _splitBinaryTopLevel(targetSentence, '&');
    if (conjuncts.length != 2) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: Failed to parse conjunction.',
      );
    }

    final normalizedSentence = _deepNormalizeParentheses(sentence);
    final normalizedLeft = _deepNormalizeParentheses(conjuncts[0]);
    final normalizedRight = _deepNormalizeParentheses(conjuncts[1]);

    if (normalizedSentence.toLowerCase() == normalizedLeft.toLowerCase() ||
        normalizedSentence.toLowerCase() == normalizedRight.toLowerCase()) {
      return const ProofValidationResult(true, '');
    }

    return ProofValidationResult(
      false,
      'Line $lineNumber: &Elim requires the conclusion $sentence to be one conjunct of the conjunction: either ${conjuncts[0]} or ${conjuncts[1]}',
    );
  }

  /// &Intro: the conclusion must be a conjunction; each conjunct must be supported by a cited line.
  static ProofValidationResult _validateAndIntro(
    String sentence,
    String citation,
    ProofPath proofPath,
    int lineNumber,
  ) {
    if (citation.trim().isEmpty) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: &Intro requires cited line numbers.',
      );
    }

    final mainConnective = _getMainConnective(sentence);
    if (mainConnective != '&') {
      return ProofValidationResult(
        false,
        'Line $lineNumber: &Intro requires the conclusion to be a conjunction, but "$sentence" is not.',
      );
    }

    final conjuncts = _splitBinaryTopLevel(sentence, '&');
    if (conjuncts.length != 2) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: Failed to parse conjunction.',
      );
    }

    final citations = citation
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    final citedSentences = <String>[];
    for (final cite in citations) {
      final targetLine = int.tryParse(cite);
      if (targetLine == null) {
        return ProofValidationResult(
          false,
          'Line $lineNumber: Invalid cited line number.',
        );
      }
      final targetSentence = _getSentenceFromLine(targetLine, proofPath);
      if (targetSentence.isEmpty) {
        return ProofValidationResult(
          false,
          'Line $lineNumber: Cited line $targetLine is empty.',
        );
      }
      citedSentences.add(targetSentence);
    }

    final normalizedConjuncts = conjuncts
        .map(_deepNormalizeParentheses)
        .map((value) => value.toLowerCase())
        .toList()
      ..sort();
    final normalizedCited = citedSentences
        .map(_deepNormalizeParentheses)
        .map((value) => value.toLowerCase())
        .toList()
      ..sort();

    if (normalizedConjuncts.length != normalizedCited.length) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: &Intro requires every conjunct to be supported by a cited line.',
      );
    }

    for (var i = 0; i < normalizedConjuncts.length; i++) {
      if (normalizedConjuncts[i] != normalizedCited[i]) {
        return ProofValidationResult(
          false,
          'Line $lineNumber: Cited sentences do not match the conjuncts.',
        );
      }
    }

    return const ProofValidationResult(true, '');
  }

  /// ~Elim (Double Negation Elimination): cited sentence must be ~~φ; conclusion must be φ.
  static ProofValidationResult _validateNegElim(
    String sentence,
    String citation,
    ProofPath proofPath,
    int lineNumber,
  ) {
    if (citation.trim().isEmpty) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: ~Elim requires a cited line number.',
      );
    }

    final targetLine = int.tryParse(citation.trim());
    if (targetLine == null) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: Invalid cited line number.',
      );
    }

    final targetSentence = _getSentenceFromLine(targetLine, proofPath);
    if (targetSentence.isEmpty) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: Cited line $targetLine is empty.',
      );
    }

    final trimmedTarget = _trimOuterParentheses(targetSentence);
    final mainConnective = _getMainConnective(trimmedTarget);
    if (mainConnective != '~' || !trimmedTarget.startsWith('~~')) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: ~Elim requires the cited sentence to be a double negation, but "$targetSentence" is not.',
      );
    }

    final negatedSentence = trimmedTarget.substring(2);
    final normalizedSentence = _deepNormalizeParentheses(sentence);
    final normalizedNegated = _deepNormalizeParentheses(negatedSentence);

    if (normalizedSentence.toLowerCase() == normalizedNegated.toLowerCase()) {
      return const ProofValidationResult(true, '');
    }

    return ProofValidationResult(
      false,
      'Line $lineNumber: ~Elim requires the conclusion to be the result of removing the double negation.',
    );
  }

  /// ~Intro (Double Negation Introduction): conclusion must be ~~premise.
  static ProofValidationResult _validateNegIntro(
    String sentence,
    String citation,
    ProofPath proofPath,
    int lineNumber,
  ) {
    if (citation.trim().isEmpty) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: ~Intro requires a cited line number.',
      );
    }

    final targetLine = int.tryParse(citation.trim());
    if (targetLine == null) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: Invalid cited line number.',
      );
    }

    final targetSentence = _getSentenceFromLine(targetLine, proofPath);
    if (targetSentence.isEmpty) {
      return ProofValidationResult(
        false,
        'Line $lineNumber: Cited line $targetLine is empty.',
      );
    }

    final mainConnective = _getMainConnective(targetSentence);
    final expectedNegation =
        (mainConnective == '&' || mainConnective == 'v')
            ? '~~(${targetSentence.trim()})'
            : '~~${targetSentence.trim()}';

    final normalizedSentence = _deepNormalizeParentheses(sentence);
    final normalizedExpected = _deepNormalizeParentheses(expectedNegation);

    if (normalizedSentence.toLowerCase() == normalizedExpected.toLowerCase()) {
      return const ProofValidationResult(true, '');
    }

    return ProofValidationResult(
      false,
      'Line $lineNumber: ~Intro requires the conclusion to be the double negation of the premise.',
    );
  }

  static String _getSentenceFromLine(int lineNumber, ProofPath proofPath) {
    if (lineNumber == 1) {
      return proofPath.premise ?? '';
    }

    final index = lineNumber - 2;
    if (index < 0 || index >= proofPath.proofLines.length) {
      return '';
    }

    return proofPath.proofLines[index].sentence;
  }

  static String _trimOuterParentheses(String sentence) {
    var s = _stripWhitespace(sentence);
    while (s.length >= 2 && s.startsWith('(') && s.endsWith(')')) {
      if (!_isFullyWrappedInParens(s)) {
        break;
      }
      s = s.substring(1, s.length - 1).trim();
    }
    return s;
  }

  static bool _isFullyWrappedInParens(String s) {
    if (!s.startsWith('(') || !s.endsWith(')')) {
      return false;
    }
    var depth = 0;
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '(') {
        depth++;
      } else if (c == ')') {
        depth--;
        if (depth == 0 && i < s.length - 1) {
          return false;
        }
      }
    }
    return depth == 0;
  }

  static String _getMainConnective(String sentence) {
    var s = _trimOuterParentheses(sentence);
    if (s.isEmpty) {
      return '';
    }

    var depth = 0;
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '(') {
        depth++;
      } else if (c == ')') {
        depth--;
      } else if (depth == 0 && (c == '&' || c == 'v')) {
        return c;
      }
    }

    if (s.startsWith('~')) {
      return '~';
    }

    return '';
  }

  static List<String> _splitBinaryTopLevel(String sentence, String connective) {
    final s = _trimOuterParentheses(sentence.trim());
    var depth = 0;
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '(') {
        depth++;
      } else if (c == ')') {
        depth--;
      } else if (depth == 0 && c == connective) {
        final left = _trimOuterParentheses(s.substring(0, i).trim());
        final right = _trimOuterParentheses(s.substring(i + 1).trim());
        return [left, right];
      }
    }
    return <String>[];
  }

  static String _deepNormalizeParentheses(String sentence) {
    final cleaned = _stripWhitespace(sentence);
    final parsed = _parseFormula(cleaned);
    if (parsed == null) {
      return cleaned;
    }
    return parsed.toNormalizedString();
  }

  static String _stripWhitespace(String sentence) {
    return sentence.replaceAll(RegExp(r'\s+'), '');
  }

  static bool _isWff(String sentence) {
    final cleaned = _stripWhitespace(sentence);
    final parsed = _parseFormula(cleaned);
    return parsed != null;
  }

  static _Formula? _parseFormula(String sentence) {
    if (sentence.isEmpty) {
      return null;
    }
    final result = _Parser(sentence, _atomicSentences).parseExpression();
    if (result == null || result.nextIndex != sentence.length) {
      return null;
    }
    return result.formula;
  }
}

class _Parser {
  _Parser(this.source, this.atomicSentences);

  final String source;
  final Set<String> atomicSentences;

  _ParseResult? parseExpression() {
    var result = _parseUnary(0);
    if (result == null) {
      return null;
    }
    var left = result.formula;
    var index = result.nextIndex;

    while (index < source.length) {
      final op = source[index];
      if (op != '&' && op != 'v') {
        break;
      }
      final rightResult = _parseUnary(index + 1);
      if (rightResult == null) {
        return null;
      }
      left = _Binary(op, left, rightResult.formula);
      index = rightResult.nextIndex;
    }

    return _ParseResult(left, index);
  }

  _ParseResult? _parseUnary(int index) {
    if (index >= source.length) {
      return null;
    }

    final c = source[index];
    if (c == '~') {
      final result = _parseUnary(index + 1);
      if (result == null) {
        return null;
      }
      return _ParseResult(_Neg(result.formula), result.nextIndex);
    }

    if (c == '(') {
      final result = _parseSubexpression(index + 1);
      if (result == null) {
        return null;
      }
      return _ParseResult(result.formula, result.nextIndex);
    }

    if (_isAtomicChar(c)) {
      return _ParseResult(_Atomic(c), index + 1);
    }

    return null;
  }

  _ParseResult? _parseSubexpression(int index) {
    final inner = _parseExpressionFrom(index);
    if (inner == null) {
      return null;
    }
    if (inner.nextIndex >= source.length || source[inner.nextIndex] != ')') {
      return null;
    }
    return _ParseResult(inner.formula, inner.nextIndex + 1);
  }

  _ParseResult? _parseExpressionFrom(int index) {
    var result = _parseUnary(index);
    if (result == null) {
      return null;
    }

    var left = result.formula;
    var i = result.nextIndex;

    while (i < source.length) {
      final op = source[i];
      if (op != '&' && op != 'v') {
        break;
      }
      final rightResult = _parseUnary(i + 1);
      if (rightResult == null) {
        return null;
      }
      left = _Binary(op, left, rightResult.formula);
      i = rightResult.nextIndex;
    }

    return _ParseResult(left, i);
  }

  bool _isAtomicChar(String c) {
    return c.length == 1 && atomicSentences.contains(c);
  }
}

class _ParseResult {
  _ParseResult(this.formula, this.nextIndex);

  final _Formula formula;
  final int nextIndex;
}

abstract class _Formula {
  String toNormalizedString();
}

class _Atomic extends _Formula {
  _Atomic(this.symbol);

  final String symbol;

  @override
  String toNormalizedString() => symbol;
}

class _Neg extends _Formula {
  _Neg(this.child);

  final _Formula child;

  @override
  String toNormalizedString() {
    final inner = child.toNormalizedString();
    if (child is _Binary) {
      return '~($inner)';
    }
    return '~$inner';
  }
}

class _Binary extends _Formula {
  _Binary(this.op, this.left, this.right);

  final String op;
  final _Formula left;
  final _Formula right;

  @override
  String toNormalizedString() {
    final leftString = left.toNormalizedString();
    final rightString = right.toNormalizedString();
    return '$leftString$op$rightString';
  }
}
