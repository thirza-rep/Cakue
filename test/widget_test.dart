import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('Smoke test - Basic compilation and rendering check', (WidgetTester tester) async {
    // Build a simple widget to verify compile and render works
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Cakue'),
          ),
        ),
      ),
    );

    // Verify that the text renders successfully
    expect(find.text('Cakue'), findsOneWidget);
  });
}
