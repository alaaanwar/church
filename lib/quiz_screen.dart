
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quiz_app_ar/question_model.dart';
import 'package:quiz_app_ar/result_screen.dart';
import 'package:quiz_app_ar/models/user_model.dart';
import 'package:quiz_app_ar/services/questions_service.dart';
import 'package:quiz_app_ar/services/answers_service.dart';
import 'package:quiz_app_ar/models/user_answer_model.dart';

class QuizScreen extends StatefulWidget {
  final User user;

  const QuizScreen({super.key, required this.user});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> questions = [];
  int current = 0;
  int score = 0;
  bool loading = true;
  bool showAnswer = false;


  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      // جلب جميع الأسئلة
      final allQuestions = await QuestionsService.getAllQuestions();
      
      // فلترة حسب عمر المستخدم والتاريخ
      final filtered = QuestionsService.filterQuestions(allQuestions, widget.user.age);
      
      setState(() {
        questions = filtered;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      debugPrint('Error loading questions: $e');
    }
  }

  void choose(int index) {
    if (showAnswer) return;
    
    final isCorrect = index == questions[current].answerIndex;
    
    // حفظ الإجابة
    final answer = UserAnswer(
      userId: widget.user.id,
      questionId: questions[current].id,
      selectedAnswer: index,
      isCorrect: isCorrect,
      answeredAt: DateTime.now(),
    );
    AnswersService.saveAnswer(answer);
    
    setState(() {
      showAnswer = true;
      if (isCorrect) {
        score += 1;
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        showAnswer = false;
        if (current < questions.length - 1) {
          current += 1;
        } else {
          // finish
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => ResultScreen(score: score, total: questions.length)),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تحميل الأسئلة...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('اختبار سريع'),
          backgroundColor: Colors.green,
        ),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.green.shade200, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sentiment_satisfied_alt, size: 80, color: Colors.green.shade400),
                const SizedBox(height: 20),
                const Text(
                  'لا توجد أسئلة متاحة اليوم',
                  style: TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'لم يتم العثور على أسئلة متاحة لك اليوم.\nيرجى الانتظار حتى يتم تحديث الأسئلة.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('العودة للرئيسية'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final q = questions[current];

    return Scaffold(
      appBar: AppBar(title: const Text('اختبار سريع')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('السؤال ${current + 1} من ${questions.length}', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(q.question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(q.options.length, (i) {
              final opt = q.options[i];
              Color bg = Colors.white;
              if (showAnswer) {
                if (i == q.answerIndex) {
                  bg = Colors.green.shade200;
                } else if (i == selectedIndex) {
                  bg = Colors.red.shade200;
                }
              }
              final hasImage = q.optionImages.length > i && q.optionImages[i] != null;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showAnswer ? bg : null,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    selectedIndex = i;
                    choose(i);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(opt, textAlign: TextAlign.right),
                        ),
                      ),
                      if (hasImage) ...[
                        const SizedBox(width: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: q.optionImages[i]!.startsWith('http')
                              ? Image.network(
                                  q.optionImages[i]!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade200,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
                                  ),
                                )
                              : Image.asset(
                                  q.optionImages[i]!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade200,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
                                  ),
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      current = 0;
                      score = 0;
                    });
                  },
                  child: const Text('أعد الاختبار'),
                ),
                Text('النتيجة: $score', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  int selectedIndex = -1;
}
