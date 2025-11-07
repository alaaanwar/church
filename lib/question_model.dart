class Question {
  final String id;
  final String question;
  final List<String> options;
  final List<String?> optionImages; // Optional images for each option
  final int answerIndex; // index of correct option
  final DateTime? targetDate; // تاريخ السؤال (null = متاح دائماً)
  final int? minAge; // الحد الأدنى للعمر (null = بدون حد)
  final int? maxAge; // الحد الأقصى للعمر (null = بدون حد)

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.answerIndex,
    this.optionImages = const [],
    this.targetDate,
    this.minAge,
    this.maxAge,
  });

  // تحقق إذا كان السؤال مناسب لعمر المستخدم
  bool isAgeAppropriate(int userAge) {
    if (minAge != null && userAge < minAge!) return false;
    if (maxAge != null && userAge > maxAge!) return false;
    return true;
  }

  // تحقق إذا كان السؤال متاح حسب التاريخ (اليوم أو الماضي فقط)
  bool isDateAvailable() {
    if (targetDate == null) return true; // متاح دائماً
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final questionDate = DateTime(targetDate!.year, targetDate!.month, targetDate!.day);
    return questionDate.isBefore(today) || questionDate.isAtSameMomentAs(today);
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      optionImages: List<String?>.from(json['optionImages'] ?? []),
      answerIndex: json['answerIndex'] ?? 0,
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      minAge: json['minAge'],
      maxAge: json['maxAge'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'optionImages': optionImages,
      'answerIndex': answerIndex,
      'targetDate': targetDate?.toIso8601String(),
      'minAge': minAge,
      'maxAge': maxAge,
    };
  }
}
