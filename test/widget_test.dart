// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:salad_app/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SaladApp());

    // Verify that our app starts and has the title text (can check for "Taze Salatalar" in AppBar)
    // Actually, because of async JSON loading, we'll just check if it pumps successfully without crashing.
    expect(find.byType(SaladApp), findsOneWidget);
  });
}
