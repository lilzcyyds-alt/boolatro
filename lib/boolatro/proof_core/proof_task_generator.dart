import 'dart:math';

import '../../game/game_config.dart';
import 'proof_validator.dart';

/// Task difficulty tiers based on the grading system.
enum Difficulty { small, big, boss }

/// Circuit complexity levels based on formula circuits.
enum CircuitLevel { one, two, three, fourPlus }

/// Formula complexity types based on specification table.
enum FormulaType {
  simple1,
  simple2,
  complex1,
  complex2,
  complex3,
  complex4,
  complex5,
  complex6,
  complex7,
}

/// Proof task generator with structured difficulty system.
class ProofTaskGenerator {

  static List<String> get _atoms => GameConfig.allowedAtoms;

  static final Random _rng = Random();

  /// Generate a proof task based on circuit level and difficulty.
  /// Returns (premise, conclusion), where conclusion is null for now.
  static (String, String?) generateTask(
    CircuitLevel circuitLevel,
    Difficulty difficulty,
  ) {
    final premise = generatePremiseByDifficulty(circuitLevel, difficulty);
    return (premise, null);
  }

  /// Generate a formula based on the specific formula type.
  static String generateFormulaByType(FormulaType formulaType) {
    switch (formulaType) {
      case FormulaType.simple1:
        return _generateSimple1();
      case FormulaType.simple2:
        return _generateSimple2();
      case FormulaType.complex1:
        return _generateComplex1();
      case FormulaType.complex2:
        return _generateComplex2();
      case FormulaType.complex3:
        return _generateComplex3();
      case FormulaType.complex4:
        return _generateComplex4();
      case FormulaType.complex5:
        return _generateComplex5();
      case FormulaType.complex6:
        return _generateComplex6();
      case FormulaType.complex7:
        return _generateComplex7();
    }
  }

  /// Generate a premise sentence consistent with the requested difficulty.
  static String generatePremiseByDifficulty(
    CircuitLevel circuitLevel,
    Difficulty difficulty,
  ) {
    final formulaType = _getFormulaTypeByTable(circuitLevel, difficulty);
    final candidate = generateFormulaByType(formulaType);
    if (_isGeneratedSentenceValid(candidate)) {
      return candidate;
    }
    return _sampleValid([() => generateFormulaByType(formulaType)]);
  }

  static FormulaType _getFormulaTypeByTable(
    CircuitLevel circuitLevel,
    Difficulty difficulty,
  ) {
    switch (circuitLevel) {
      case CircuitLevel.one:
        switch (difficulty) {
          case Difficulty.small:
            return FormulaType.simple1;
          case Difficulty.big:
            return FormulaType.complex1;
          case Difficulty.boss:
            return FormulaType.complex2;
        }
      case CircuitLevel.two:
        switch (difficulty) {
          case Difficulty.small:
            return FormulaType.simple2;
          case Difficulty.big:
            return FormulaType.complex2;
          case Difficulty.boss:
            return FormulaType.complex3;
        }
      case CircuitLevel.three:
        switch (difficulty) {
          case Difficulty.small:
            return FormulaType.complex4;
          case Difficulty.big:
            return FormulaType.complex6;
          case Difficulty.boss:
            return FormulaType.complex7;
        }
      case CircuitLevel.fourPlus:
        switch (difficulty) {
          case Difficulty.small:
            return FormulaType.complex5;
          case Difficulty.big:
            return FormulaType.complex6;
          case Difficulty.boss:
            return FormulaType.complex7;
        }
    }
  }

  /// Simple-1: ^X&^Y, atoms always random, $, %, ^ nothing.
  static String _generateSimple1() {
    final x = _atom();
    final y = _atomAvoidDup([x]);
    return _conj(x, y);
  }

  /// Simple-2: one of ^ is ~~.
  static String _generateSimple2() {
    final x = _atom();
    final y = _atomAvoidDup([x]);
    if (_rng.nextDouble() < 0.5) {
      return _conj(_doubleNeg(x), y);
    }
    return _conj(x, _doubleNeg(y));
  }

  /// Complex-1: choose A: $X&%(^Y&^Z) or B: %(^Y&^Z)&%X.
  static String _generateComplex1() {
    final x = _atom();
    final y = _atomAvoidDup([x]);
    final z = _atomAvoidDup([x, y]);

    final percentPart = _conj(y, z);
    if (_rng.nextDouble() < 0.5) {
      return _conj(x, _paren(percentPart));
    }
    return _conj(_paren(percentPart), x);
  }

  /// Complex-2: two of $, ^, ^ are ~~.
  static String _generateComplex2() {
    final x = _atom();
    final y = _atomAvoidDup([x]);
    final z = _atomAvoidDup([x, y]);

    final positions = [0, 1, 2]..shuffle(_rng);
    final selected = positions.take(2).toSet();

    final atom1 = selected.contains(0) ? _doubleNeg(x) : x;
    final atom2 = selected.contains(1) ? _doubleNeg(y) : y;
    final atom3 = selected.contains(2) ? _doubleNeg(z) : z;

    if (_rng.nextDouble() < 0.5) {
      return _conj(_paren(_conj(atom1, atom2)), atom3);
    }
    return _conj(atom1, _paren(_conj(atom2, atom3)));
  }

  /// Complex-3: Complex-2, plus % is ~~.
  static String _generateComplex3() {
    final x = _atom();
    final y = _atomAvoidDup([x]);
    final z = _atomAvoidDup([x, y]);

    final positions = [0, 1, 2]..shuffle(_rng);
    final selected = positions.take(2).toSet();

    final atom1 = selected.contains(0) ? _doubleNeg(x) : x;
    final atom2 = selected.contains(1) ? _doubleNeg(y) : y;
    final atom3 = selected.contains(2) ? _doubleNeg(z) : z;

    if (_rng.nextDouble() < 0.5) {
      return _conj(_doubleNeg(_paren(_conj(atom1, atom2))), atom3);
    }
    return _conj(atom1, _doubleNeg(_paren(_conj(atom2, atom3))));
  }

  /// Complex-4: two of $, ^, ^ are ~.
  static String _generateComplex4() {
    final x = _atom();
    final y = _atomAvoidDup([x]);
    final z = _atomAvoidDup([x, y]);

    final positions = [0, 1, 2]..shuffle(_rng);
    final selected = positions.take(2).toSet();

    final atom1 = selected.contains(0) ? _neg(x) : x;
    final atom2 = selected.contains(1) ? _neg(y) : y;
    final atom3 = selected.contains(2) ? _neg(z) : z;

    return _conj(atom1, _conj(atom2, atom3));
  }

  /// Complex-5: two of $, ^, ^ are ~ or ~~.
  static String _generateComplex5() {
    final x = _atom();
    final y = _atomAvoidDup([x]);
    final z = _atomAvoidDup([x, y]);

    final positions = [0, 1, 2]..shuffle(_rng);
    final selected = positions.take(2).toSet();

    final atom1 = selected.contains(0) ? _randomNegOrDouble(x) : x;
    final atom2 = selected.contains(1) ? _randomNegOrDouble(y) : y;
    final atom3 = selected.contains(2) ? _randomNegOrDouble(z) : z;

    return _conj(atom1, _conj(atom2, atom3));
  }

  /// Complex-6: % is ~~; $,^,^ are one each ~,~~,none.
  static String _generateComplex6() {
    final x = _atom();
    final y = _atomAvoidDup([x]);
    final z = _atomAvoidDup([x, y]);

    final modifiers = ['~', '~~', 'none']..shuffle(_rng);

    final atom1 = _applyModifier(x, modifiers[0]);
    final atom2 = _applyModifier(y, modifiers[1]);
    final atom3 = _applyModifier(z, modifiers[2]);

    return _doubleNeg(_paren(_conj(atom1, _conj(atom2, atom3))));
  }

  /// Complex-7: $,^,^ are one each ~,~~,(~~~ or none).
  static String _generateComplex7() {
    final x = _atom();
    final y = _atomAvoidDup([x]);
    final z = _atomAvoidDup([x, y]);

    final thirdModifier = _rng.nextDouble() < 0.5 ? '~~~' : 'none';
    final modifiers = ['~', '~~', thirdModifier]..shuffle(_rng);

    final atom1 = _applyModifier(x, modifiers[0]);
    final atom2 = _applyModifier(y, modifiers[1]);
    final atom3 = _applyModifier(z, modifiers[2]);

    return _conj(atom1, _conj(atom2, atom3));
  }

  static String _sampleValid(List<String Function()> generators, [int attempts = 20]) {
    for (var i = 0; i < attempts; i++) {
      final s = generators[_rng.nextInt(generators.length)]();
      if (_isGeneratedSentenceValid(s)) {
        return s;
      }
    }
    return _conj('A', 'B');
  }

  static bool _isGeneratedSentenceValid(String s) {
    if (s.trim().isEmpty) {
      return false;
    }

    if (!ProofValidator.isWellFormedFormula(s)) {
      return false;
    }

    final mc = _getMainConnectiveTopLevel(s);
    if (mc == '&') {
      final parts = _splitBinaryTopLevel(s, '&');
      if (parts.length == 2 && _areComplementaryTrimmed(parts[0], parts[1])) {
        return false;
      }
    }

    if (!_isFormulaPatternValid(s)) {
      return false;
    }

    return true;
  }

  static bool _isFormulaPatternValid(String formula) {
    if (_getMaxNestingDepth(formula) > 5) {
      return false;
    }
    if (formula.length > 100) {
      return false;
    }
    if (formula.contains('~~~') && !_isTripleNegationWellFormed(formula)) {
      return false;
    }
    if (!_areAtomsValid(formula)) {
      return false;
    }
    return true;
  }

  static bool _isTripleNegationWellFormed(String formula) {
    final index = formula.indexOf('~~~');
    if (index != -1 && index + 3 < formula.length) {
      final nextChar = formula[index + 3];
      return _isUppercaseLetter(nextChar);
    }
    return true;
  }

  static bool _areAtomsValid(String formula) {
    const allowedAtoms = {'A', 'B', 'C', 'D', 'E', 'P', 'Q', 'R'};
    for (var i = 0; i < formula.length; i++) {
      final c = formula[i];
      if (_isUppercaseLetter(c) && !allowedAtoms.contains(c)) {
        return false;
      }
    }
    return true;
  }

  static bool _areComplementaryTrimmed(String a, String b) {
    var na = _trimParens(a.trim());
    var nb = _trimParens(b.trim());

    if (na.startsWith('~')) {
      return _trimParens(na.substring(1)).toLowerCase() ==
          _trimParens(nb).toLowerCase();
    }
    if (nb.startsWith('~')) {
      return _trimParens(nb.substring(1)).toLowerCase() ==
          _trimParens(na).toLowerCase();
    }
    return false;
  }

  static String _trimParens(String s) {
    var current = s;
    while (current.length >= 2 &&
        current.startsWith('(') &&
        current.endsWith(')')) {
      if (!_isFullyWrappedInParens(current)) {
        break;
      }
      current = current.substring(1, current.length - 1);
    }
    return current;
  }

  static String _getMainConnectiveTopLevel(String s) {
    var depth = 0;
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '(') {
        depth++;
      } else if (c == ')') {
        depth--;
      } else if (depth == 0 && (c == '&' || c == '~')) {
        return c;
      }
    }
    return '\0';
  }

  static List<String> _splitBinaryTopLevel(String s, String op) {
    var depth = 0;
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '(') {
        depth++;
      } else if (c == ')') {
        depth--;
      } else if (depth == 0 && c == op) {
        final left = _trimParens(s.substring(0, i).trim());
        final right = _trimParens(s.substring(i + 1).trim());
        return [left, right];
      }
    }
    return <String>[];
  }

  static int _getMaxNestingDepth(String formula) {
    var maxDepth = 0;
    var currentDepth = 0;
    for (var i = 0; i < formula.length; i++) {
      final c = formula[i];
      if (c == '(') {
        currentDepth++;
        if (currentDepth > maxDepth) {
          maxDepth = currentDepth;
        }
      } else if (c == ')') {
        currentDepth--;
      }
    }
    return maxDepth;
  }

  static String _atom() => _atoms[_rng.nextInt(_atoms.length)];

  static String _atomAvoidDup(List<String> avoid) {
    var atom = _atom();
    while (avoid.contains(atom)) {
      atom = _atom();
    }
    return atom;
  }

  static String _neg(String s) => '~$s';

  static String _doubleNeg(String s) => '~~$s';

  static String _paren(String s) => '($s)';

  static String _conj(String a, String b) {
    var rightPart = b;
    if (b.contains('&') || b.contains('v')) {
      if (!_isFullyWrappedInParens(b)) {
        rightPart = '($b)';
      }
    }
    return '$a&$rightPart';
  }

  static bool _isFullyWrappedInParens(String s) {
    if (!s.startsWith('(') || !s.endsWith(')')) {
      return false;
    }

    var depth = 0;
    for (var i = 0; i < s.length; i++) {
      if (s[i] == '(') {
        depth++;
      } else if (s[i] == ')') {
        depth--;
        if (depth == 0 && i < s.length - 1) {
          return false;
        }
      }
    }
    return true;
  }

  static String _applyModifier(String atom, String modifier) {
    switch (modifier) {
      case '~':
        return _neg(atom);
      case '~~':
        return _doubleNeg(atom);
      case '~~~':
        return '~~~$atom';
      case 'none':
        return atom;
      default:
        return atom;
    }
  }

  static String _randomNegOrDouble(String atom) {
    return _rng.nextDouble() < 0.5 ? _neg(atom) : _doubleNeg(atom);
  }

  static bool _isUppercaseLetter(String value) {
    if (value.length != 1) {
      return false;
    }
    final code = value.codeUnitAt(0);
    return code >= 65 && code <= 90;
  }
}
