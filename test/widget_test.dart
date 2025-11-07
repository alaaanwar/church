// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quiz_app_ar/question_model.dart';
import 'package:quiz_app_ar/quiz_screen.dart';

void main() {
  testWidgets('QuizScreen shows injected question and options', (WidgetTester tester) async {
    // Create a small sample question list to inject (no network required).
    final sample = [
      Question(
        id: 't1',
        question: 'اختبار: ما هي النتيجة؟',
        options: ['أ', 'ب', 'ج', 'د'],
        answerIndex: 1,
      ),
    ];

    // Pump the widget with injected questions.
    await tester.pumpWidget(MaterialApp(home: QuizScreen(initialQuestions: sample)));

    // Allow frames to settle.
    await tester.pumpAndSettle();

    // Verify the question text and one of the options appears.
    expect(find.text('اختبار: ما هي النتيجة؟'), findsOneWidget);
    expect(find.text('ب'), findsOneWidget);
  });
}
