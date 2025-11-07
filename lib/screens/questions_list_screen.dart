import 'package:flutter/material.dart';
import 'package:quiz_app_ar/question_model.dart';
import 'package:quiz_app_ar/services/questions_service.dart';
import 'package:quiz_app_ar/screens/edit_question_screen.dart';

class QuestionsListScreen extends StatefulWidget {
  const QuestionsListScreen({super.key});

  @override
  State<QuestionsListScreen> createState() => _QuestionsListScreenState();
}

class _QuestionsListScreenState extends State<QuestionsListScreen> {
  List<Question> _questions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _loading = true);
    final questions = await QuestionsService.getAllQuestions();
    setState(() {
      _questions = questions;
      _loading = false;
    });
  }

  Future<void> _deleteQuestion(Question question) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف', textAlign: TextAlign.right),
        content: const Text(
          'هل تريد حذف هذا السؤال نهائياً؟',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await QuestionsService.deleteQuestion(question.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف السؤال')),
      );
      _loadQuestions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأسئلة'),
        backgroundColor: Colors.green,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? Center(
                  child: Container(
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
                        SizedBox(height: 20),
                        Text(
                          'لا توجد أسئلة متاحة اليوم',
                          style: TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'لم يتم العثور على أسئلة متاحة لهذا اليوم.\nانتظر تحديث الأسئلة أو تواصل مع المسؤول لإضافة المزيد.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      child: ExpansionTile(
                        title: Text(
                          question.question,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'التاريخ: ${question.targetDate} • العمر: ${question.minAge}-${question.maxAge}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 12),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'الخيارات:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 8),
                                ...question.options.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final option = entry.value;
                                  final isCorrect = idx == question.answerIndex;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${idx + 1}. $option',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              color: isCorrect ? Colors.green : null,
                                              fontWeight: isCorrect ? FontWeight.bold : null,
                                            ),
                                          ),
                                        ),
                                        if (isCorrect)
                                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                      ],
                                    ),
                                  );
                                }),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditQuestionScreen(question: question),
                                          ),
                                        );
                                        if (result == true) _loadQuestions();
                                      },
                                      icon: const Icon(Icons.edit),
                                      label: const Text('تعديل'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _deleteQuestion(question),
                                      icon: const Icon(Icons.delete),
                                      label: const Text('حذف'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
