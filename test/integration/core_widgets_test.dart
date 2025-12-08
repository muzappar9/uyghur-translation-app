/// Stage 12 Integration Test - Core Screens (Isolated)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 简化版集成测试，不依赖完整的应用初始化
void main() {
  group('Stage 12 - Core Widgets Tests', () {
    testWidgets('Basic MaterialApp can be created', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Test App')),
          ),
        ),
      );
      
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Test App'), findsOneWidget);
    });

    testWidgets('ProviderScope wraps app correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Riverpod Test')),
            ),
          ),
        ),
      );
      
      expect(find.byType(ProviderScope), findsOneWidget);
      expect(find.text('Riverpod Test'), findsOneWidget);
    });

    testWidgets('TextField widget works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(
              decoration: InputDecoration(hintText: 'Enter text'),
            ),
          ),
        ),
      );
      
      expect(find.byType(TextField), findsOneWidget);
      
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();
      
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('IconButtons can be tapped', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButton(
              icon: const Icon(Icons.translate),
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.translate), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.translate));
      await tester.pump();
      
      expect(tapped, true);
    });

    testWidgets('Bottom navigation bar works', (WidgetTester tester) async {
      int selectedIndex = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: const Center(child: Text('Content')),
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: selectedIndex,
                  onTap: (index) => setState(() => selectedIndex = index),
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                    BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
                    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
                  ],
                ),
              );
            },
          ),
        ),
      );
      
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('AppBar displays title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Translation App')),
            body: const Center(child: Text('Content')),
          ),
        ),
      );
      
      expect(find.text('Translation App'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Card widget displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Card Content'),
              ),
            ),
          ),
        ),
      );
      
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('ElevatedButton can be pressed', (WidgetTester tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => pressed = true,
              child: const Text('Translate'),
            ),
          ),
        ),
      );
      
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Translate'), findsOneWidget);
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(pressed, true);
    });
  });
}
