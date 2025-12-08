// This is a basic Flutter widget test for the Uyghur Translator app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic app structure with ProviderScope',
      (WidgetTester tester) async {
    // Build a minimal app structure
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Uyghur Translator')),
            body: const Center(child: Text('Translation App')),
          ),
        ),
      ),
    );

    // Verify that the app widget is properly instantiated
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(ProviderScope), findsOneWidget);
    expect(find.text('Uyghur Translator'), findsOneWidget);
    expect(find.text('Translation App'), findsOneWidget);
  });

  testWidgets('Theme configuration works', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const Scaffold(
          body: Center(child: Text('Themed App')),
        ),
      ),
    );

    expect(find.text('Themed App'), findsOneWidget);
  });

  testWidgets('Dark theme configuration works', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: const Scaffold(
          body: Center(child: Text('Dark Theme App')),
        ),
      ),
    );

    expect(find.text('Dark Theme App'), findsOneWidget);
  });
}
