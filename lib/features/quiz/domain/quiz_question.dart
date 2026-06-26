class QuizQuestion {
  final int id;
  final String category;
  final String difficulty;
  final int points;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String tafsirInsight;

  const QuizQuestion({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.points,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.tafsirInsight,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as int,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      points: json['points'] as int,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as Iterable),
      correctOptionIndex: json['correct_option_index'] as int,
      tafsirInsight: json['tafsir_insight'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'difficulty': difficulty,
      'points': points,
      'question': question,
      'options': options,
      'correct_option_index': correctOptionIndex,
      'tafsir_insight': tafsirInsight,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizQuestion &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
