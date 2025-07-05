// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pangocalc/main.dart';

void main() {
  testWidgets('Calculator app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PangoCalcApp());

    // Verify that our calculator starts with 0 displayed.
    expect(find.text('0'), findsOneWidget);

    // Verify that the app title is displayed.
    expect(find.text('Pangolock Calculator'), findsOneWidget);
  });
}
