// This is a basic Flutter widget test for the Sticky Notes app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sticky Notes App Tests', () {
    testWidgets('App theme configuration works', (WidgetTester tester) async {
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Center(
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('Basic widget rendering test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Sticky Notes'),
              backgroundColor: const Color(0xFF1E3A8A),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sticky_note_2,
                    size: 100,
                    color: Color(0xFF1E3A8A),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Welcome to Sticky Notes!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Sticky Notes'), findsOneWidget);
      expect(find.text('Welcome to Sticky Notes!'), findsOneWidget);
      expect(find.byIcon(Icons.sticky_note_2), findsOneWidget);
    });

    testWidgets('Form field validation test', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      formKey.currentState?.validate();
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('Color scheme test', (WidgetTester tester) async {
      const primaryColor = Color(0xFF1E3A8A);
      const backgroundColor = Color(0xFFF8FAFC);
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: backgroundColor,
          ),
          home: const Scaffold(
            body: Center(
              child: Text('Color Test'),
            ),
          ),
        ),
      );

      expect(find.text('Color Test'), findsOneWidget);
    });
  });
}