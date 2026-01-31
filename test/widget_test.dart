import 'package:flutter_test/flutter_test.dart';

import 'package:boolatro/main.dart';

void main() {
  testWidgets('Game screen shows start phase', (WidgetTester tester) async {
    await tester.pumpWidget(const BoolatroApp());

    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Begin Run'), findsOneWidget);
  });
}
