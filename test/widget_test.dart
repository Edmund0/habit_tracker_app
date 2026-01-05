import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MomentumApp());

    // Verify the app title appears
    expect(find.text('Momentum'), findsOneWidget);
  });
}
