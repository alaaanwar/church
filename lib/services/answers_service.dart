import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz_app_ar/models/user_answer_model.dart';

class AnswersService {
  static const String _answersKey = 'user_answers';

  // حفظ إجابة مستخدم
  static Future<void> saveAnswer(UserAnswer answer) async {
    final answers = await getAllAnswers();
    answers.add(answer);
    await _saveAllAnswers(answers);
  }

  // الحصول على جميع الإجابات
  static Future<List<UserAnswer>> getAllAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    final answersJson = prefs.getString(_answersKey);
    if (answersJson == null) return [];

    final List<dynamic> answersList = json.decode(answersJson);
    return answersList.map((a) => UserAnswer.fromJson(a)).toList();
  }

  // حفظ جميع الإجابات
  static Future<void> _saveAllAnswers(List<UserAnswer> answers) async {
    final prefs = await SharedPreferences.getInstance();
    final answersJson = answers.map((a) => a.toJson()).toList();
    await prefs.setString(_answersKey, json.encode(answersJson));
  }

  // الحصول على إحصائيات مستخدم معين
  static Future<Map<String, int>> getUserStats(String userId) async {
    final answers = await getAllAnswers();
    final userAnswers = answers.where((a) => a.userId == userId).toList();

    final correct = userAnswers.where((a) => a.isCorrect).length;
    final wrong = userAnswers.where((a) => !a.isCorrect).length;

    return {
      'total': userAnswers.length,
      'correct': correct,
      'wrong': wrong,
    };
  }

  // التحقق إذا كان المستخدم أجاب على سؤال معين
  static Future<bool> hasAnswered(String userId, String questionId) async {
    final answers = await getAllAnswers();
    return answers.any((a) => a.userId == userId && a.questionId == questionId);
  }

  // الحصول على إجابات مستخدم معين
  static Future<List<UserAnswer>> getUserAnswers(String userId) async {
    final answers = await getAllAnswers();
    return answers.where((a) => a.userId == userId).toList();
  }
}
