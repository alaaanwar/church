class UserAnswer {
  final String userId;
  final String questionId;
  final int selectedAnswer;
  final bool isCorrect;
  final DateTime answeredAt;

  UserAnswer({
    required this.userId,
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.answeredAt,
  });

  factory UserAnswer.fromJson(Map<String, dynamic> json) {
    return UserAnswer(
      userId: json['userId'] ?? '',
      questionId: json['questionId'] ?? '',
      selectedAnswer: json['selectedAnswer'] ?? 0,
      isCorrect: json['isCorrect'] ?? false,
      answeredAt: DateTime.parse(json['answeredAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }
}
