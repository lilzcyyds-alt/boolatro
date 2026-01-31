import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boolatro/main.dart';

Future<void> _advanceToProofPhase(WidgetTester tester) async {
  await tester.pumpWidget(const BoolatroApp());
  await tester.pump(const Duration(milliseconds: 16));

  await tester.tap(find.text('Begin Run'));
  await tester.pump(const Duration(milliseconds: 16));

  await tester.tap(find.text('Lock Blind'));
  await tester.pump(const Duration(milliseconds: 16));
}

String _readPremise(WidgetTester tester) {
  final Text premiseText =
      tester.widget<Text>(find.byKey(const Key('proof-premise')));
  final String? data = premiseText.data;
  return data == null ? '' : data.replaceFirst('Premise: ', '');
}

Future<void> _enterConclusionByTapping(
  WidgetTester tester,
  String conclusion,
) async {
  for (final rune in conclusion.runes) {
    final char = String.fromCharCode(rune);
    if (char.trim().isEmpty) {
      continue;
    }
    await tester.tap(find.byKey(ValueKey('hand-card-$char')));
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('Proof phase generates a premise task',
      (WidgetTester tester) async {
    await _advanceToProofPhase(tester);

    final premise = _readPremise(tester);
    expect(premise.isNotEmpty, isTrue);
  });

  testWidgets('Enter proof editor after building a conclusion',
      (WidgetTester tester) async {
    await _advanceToProofPhase(tester);

    await tester.tap(find.byKey(const ValueKey('hand-card-P')));
    await tester.pump(const Duration(milliseconds: 16));

    final Finder enterButton = find.byKey(const Key('enter-proof-editor'));
    final ElevatedButton button = tester.widget<ElevatedButton>(enterButton);
    expect(button.onPressed, isNotNull);

    await tester.tap(enterButton);
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.text('Proof Editor'), findsOneWidget);
  });

  testWidgets('Submitting invalid proof shows an error',
      (WidgetTester tester) async {
    await _advanceToProofPhase(tester);

    await tester.tap(find.byKey(const ValueKey('hand-card-P')));
    await tester.pump(const Duration(milliseconds: 16));

    await tester.tap(find.byKey(const Key('enter-proof-editor')));
    await tester.pump(const Duration(milliseconds: 16));

    await tester.tap(find.text('Submit'));
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.textContaining('Proof must have at least one line'),
        findsOneWidget);
  });

  testWidgets('Submitting minimal valid proof passes',
      (WidgetTester tester) async {
    await _advanceToProofPhase(tester);

    final premise = _readPremise(tester);
    await _enterConclusionByTapping(tester, premise);

    await tester.tap(find.byKey(const Key('enter-proof-editor')));
    await tester.pump(const Duration(milliseconds: 16));

    await tester.tap(find.text('Add Line'));
    await tester.pump(const Duration(milliseconds: 16));

    await tester.enterText(
      find.byKey(const ValueKey('proof-line-1-sentence')),
      premise,
    );
    await tester.pump(const Duration(milliseconds: 16));

    await tester.enterText(
      find.byKey(const ValueKey('proof-line-1-citations')),
      '1',
    );
    await tester.pump(const Duration(milliseconds: 16));

    await tester.tap(find.text('Submit'));
    await tester.pump(const Duration(milliseconds: 16));

    // Phase 3 can immediately clear the blind and transition to Cashout.
    final passedCount = find.textContaining('Proof validation passed').evaluate().length;
    final cashoutCount = find.text('Cashout').evaluate().length;
    expect(passedCount + cashoutCount, greaterThan(0));
  });
}
