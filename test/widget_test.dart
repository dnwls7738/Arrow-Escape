import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const ArrowEscapeApp());
    expect(find.text('PUZZLE ESCAPE'), findsOneWidget);
  });
}
