import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';
import 'package:frontend/di/service_locator.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    setupServiceLocator();
    await tester.pumpWidget(const LevelApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
