// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:actime_desktop/main.dart';

void main() {
  testWidgets('Admin login screen loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ActimeAdminApp());

    // Verify that login screen is displayed
    expect(find.text('Welcome to Actime'), findsOneWidget);
    expect(find.text('Administrator Panel'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
  });
}