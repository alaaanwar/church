import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiz_app_ar/question_model.dart';
import 'package:quiz_app_ar/config/api_config.dart';

class QuestionsService {
  // إضافة سؤال جديد (أونلاين)
  static Future<void> addQuestion(Question question) async {
    final questions = await getAllQuestions();
    questions.add(question);
    await _saveQuestionsOnline(questions);
  }

  // الحصول على جميع الأسئلة (أونلاين)
  static Future<List<Question>> getAllQuestions() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/b/${ApiConfig.questionsBinId}/latest'),
        headers: {
          'X-Master-Key': ApiConfig.jsonBinApiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> questionsList = data['record'] ?? [];
        return questionsList.map((q) => Question.fromJson(q)).toList();
      }
    } catch (e) {
      print('Error fetching questions: $e');
    }
    return [];
  }

  // حفظ الأسئلة أونلاين
  static Future<void> _saveQuestionsOnline(List<Question> questions) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/b/${ApiConfig.questionsBinId}'),
        headers: {
          'Content-Type': 'application/json',
          'X-Master-Key': ApiConfig.jsonBinApiKey,
        },
        body: json.encode(questions.map((q) => q.toJson()).toList()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save questions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving questions: $e');
      rethrow;
    }
  }


  // فلترة الأسئلة حسب عمر المستخدم والتاريخ
  static List<Question> filterQuestions(List<Question> questions, int userAge) {
    final now = DateTime.now();
    return questions.where((q) {
      // تحقق من العمر
      if (!q.isAgeAppropriate(userAge)) return false;
      // تحقق من التاريخ (اليوم والماضي فقط)
      if (!q.isDateAvailable()) return false;
      return true;
    }).toList();
  }

  // حذف سؤال أونلاين
  static Future<void> deleteQuestion(String questionId) async {
    final questions = await getAllQuestions();
    questions.removeWhere((q) => q.id == questionId);
    await _saveQuestionsOnline(questions);
  }

  // تحديث سؤال أونلاين
  static Future<void> updateQuestion(Question question) async {
    final questions = await getAllQuestions();
    final index = questions.indexWhere((q) => q.id == question.id);
    if (index != -1) {
      questions[index] = question;
      await _saveQuestionsOnline(questions);
    }
  }
}
