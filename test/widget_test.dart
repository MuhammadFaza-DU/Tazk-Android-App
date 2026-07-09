import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/main.dart';

void main() {
  testWidgets('TazkApp renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const TazkApp());

    expect(find.text('Tazk'), findsWidgets);
  });
}
