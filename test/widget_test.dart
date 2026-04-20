// Basic Flutter widget test for Smart Dental Diagnosis app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dentist/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // App should show splash then navigate; expect either splash title or home/login content
    expect(
      find.text('Smart Dental Diagnosis').evaluate().isNotEmpty ||
          find.byIcon(Icons.medical_services).evaluate().isNotEmpty,
      true,
    );
  });
}
