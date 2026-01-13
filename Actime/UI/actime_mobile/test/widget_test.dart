// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:actime_mobile/main.dart';

void main() {
  testWidgets('Sign In screen loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ActimeApp());

    // Verify that Sign In screen is displayed
    expect(find.text('Actime'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
    expect(find.byType(TextField), findsWidgets);
  });
}