import 'package:flutter_test/flutter_test.dart';

import 'package:boolatro/boolatro/proof_core/proof_core.dart';

void main() {
  group('ProofValidator WFF', () {
    test('accepts valid formulas', () {
      final valid = [
        'P',
        '~P',
        '~~P',
        '(P&Q)',
        '~(P&Q)',
        '(~P)&(~~Q)',
        '((P))',
      ];

      for (final formula in valid) {
        expect(
          ProofValidator.isWellFormedFormula(formula),
          isTrue,
          reason: 'Expected WFF for $formula',
        );
      }
    });

    test('rejects invalid formulas', () {
      final invalid = [
        '',
        '&P',
        'P&',
        '(P',
        'P))',
        'P&Q&',
      ];

      for (final formula in invalid) {
        expect(
          ProofValidator.isWellFormedFormula(formula),
          isFalse,
          reason: 'Expected invalid for $formula',
        );
      }
    });
  });

  group('ProofValidator rules', () {
    test('reit validates exact match', () {
      final path = ProofPath(premise: 'P');
      final line = ProofLine(sentence: 'P', rule: 'reit', citationsRaw: '1');
      final result = ProofValidator.validateProofLine(line, path, 2);
      expect(result.isValid, isTrue, reason: result.message);
    });

    test('&elim validates conjunct', () {
      final path = ProofPath(premise: 'P&Q');
      final line = ProofLine(sentence: 'P', rule: '&elim', citationsRaw: '1');
      final result = ProofValidator.validateProofLine(line, path, 2);
      expect(result.isValid, isTrue, reason: result.message);
    });

    test('&intro validates cited conjuncts', () {
      final path = ProofPath(
        premise: 'P',
        proofLines: [
          const ProofLine(sentence: 'Q', rule: 'reit', citationsRaw: '1'),
        ],
      );
      final line = ProofLine(sentence: 'P&Q', rule: '&intro', citationsRaw: '1,2');
      final result = ProofValidator.validateProofLine(line, path, 3);
      expect(result.isValid, isTrue, reason: result.message);
    });

    test('~elim validates double negation elimination', () {
      final path = ProofPath(premise: '~~P');
      final line = ProofLine(sentence: 'P', rule: '~elim', citationsRaw: '1');
      final result = ProofValidator.validateProofLine(line, path, 2);
      expect(result.isValid, isTrue, reason: result.message);
    });

    test('~intro validates double negation introduction', () {
      final path = ProofPath(premise: 'P&Q');
      final line = ProofLine(
        sentence: '~~(P&Q)',
        rule: '~intro',
        citationsRaw: '1',
      );
      final result = ProofValidator.validateProofLine(line, path, 2);
      expect(result.isValid, isTrue, reason: result.message);
    });
  });

  group('ProofValidator conclusion consistency', () {
    test('matches normalized conclusion', () {
      final path = ProofPath(
        premise: 'P',
        conclusion: 'P&Q',
        proofLines: const [
          ProofLine(sentence: '(P)&(Q)', rule: '&intro', citationsRaw: '1,1'),
        ],
      );

      final result = ProofValidator.validateProofConclusionConsistency(path);
      expect(result.isValid, isTrue, reason: result.message);
    });
  });

  group('ProofTaskGenerator', () {
    test('generates WFF across table combos', () {
      for (final circuit in CircuitLevel.values) {
        for (final difficulty in Difficulty.values) {
          final (premise, conclusion) =
              ProofTaskGenerator.generateTask(circuit, difficulty);
          expect(conclusion, isNull);
          expect(premise.trim().isNotEmpty, isTrue);
          expect(ProofValidator.isWellFormedFormula(premise), isTrue);
        }
      }
    });
  });
}
