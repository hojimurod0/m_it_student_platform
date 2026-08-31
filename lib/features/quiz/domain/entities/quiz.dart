import 'package:flutter/material.dart';

enum QuizCategory {
  flutter,
  dart,
  python,
  frontend,
  git,
  algorithms,
  backend,
  general;

  String get label => switch (this) {
        QuizCategory.flutter => 'Flutter',
        QuizCategory.dart => 'Dart',
        QuizCategory.python => 'Python',
        QuizCategory.frontend => 'Frontend',
        QuizCategory.git => 'Git & GitHub',
        QuizCategory.algorithms => 'Algoritmlar',
        QuizCategory.backend => 'Backend',
        QuizCategory.general => 'Umumiy IT',
      };

  IconData get icon => switch (this) {
        QuizCategory.flutter => Icons.flutter_dash,
        QuizCategory.dart => Icons.code,
        QuizCategory.python => Icons.terminal,
        QuizCategory.frontend => Icons.web,
        QuizCategory.git => Icons.merge_type,
        QuizCategory.algorithms => Icons.psychology,
        QuizCategory.backend => Icons.dns,
        QuizCategory.general => Icons.school,
      };

  Color get color => switch (this) {
        QuizCategory.flutter => const Color(0xFF02569B),
        QuizCategory.dart => const Color(0xFF0175C2),
        QuizCategory.python => const Color(0xFF3776AB),
        QuizCategory.frontend => const Color(0xFFE44D26),
        QuizCategory.git => const Color(0xFFF05032),
        QuizCategory.algorithms => const Color(0xFF9C27B0),
        QuizCategory.backend => const Color(0xFF009688),
        QuizCategory.general => const Color(0xFF4CAF50),
      };
}

enum QuizDifficulty {
  easy,
  medium,
  hard;

  String get label => switch (this) {
        QuizDifficulty.easy => 'Oson',
        QuizDifficulty.medium => 'O\'rta',
        QuizDifficulty.hard => 'Qiyin',
      };

  Color get color => switch (this) {
        QuizDifficulty.easy => const Color(0xFF4CAF50),
        QuizDifficulty.medium => const Color(0xFFFF9800),
        QuizDifficulty.hard => const Color(0xFFF44336),
      };
}

/// Pure Domain Entity: Savol (QuizQuestion) ob'ekti
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final QuizCategory category;
  final QuizDifficulty difficulty;
  final int coinReward;
  final int xpReward;
  final String? codeSnippet;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.category = QuizCategory.flutter,
    this.difficulty = QuizDifficulty.medium,
    this.coinReward = 10,
    this.xpReward = 10,
    this.codeSnippet,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizQuestion && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
