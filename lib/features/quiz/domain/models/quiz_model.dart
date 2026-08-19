import 'package:flutter/material.dart';

enum QuizCategory {
  flutter,
  dart,
  python,
  frontend,
  backend,
  git,
  algorithms,
}

enum QuizDifficulty {
  easy,
  medium,
  hard,
}

extension QuizCategoryExt on QuizCategory {
  String get label => switch (this) {
        QuizCategory.flutter => 'Flutter',
        QuizCategory.dart => 'Dart OOP',
        QuizCategory.python => 'Python & AI',
        QuizCategory.frontend => 'Frontend',
        QuizCategory.backend => 'Backend & DB',
        QuizCategory.git => 'Git & DevOps',
        QuizCategory.algorithms => 'Algoritmlar',
      };

  IconData get icon => switch (this) {
        QuizCategory.flutter => Icons.flutter_dash_rounded,
        QuizCategory.dart => Icons.code_rounded,
        QuizCategory.python => Icons.terminal_rounded,
        QuizCategory.frontend => Icons.web_rounded,
        QuizCategory.backend => Icons.dns_rounded,
        QuizCategory.git => Icons.merge_type_rounded,
        QuizCategory.algorithms => Icons.psychology_rounded,
      };

  Color get color => switch (this) {
        QuizCategory.flutter => const Color(0xFF02569B),
        QuizCategory.dart => const Color(0xFF0075C9),
        QuizCategory.python => const Color(0xFF3776AB),
        QuizCategory.frontend => const Color(0xFFE34F26),
        QuizCategory.backend => const Color(0xFF10B981),
        QuizCategory.git => const Color(0xFFF05032),
        QuizCategory.algorithms => const Color(0xFF8B5CF6),
      };
}

extension QuizDifficultyExt on QuizDifficulty {
  String get label => switch (this) {
        QuizDifficulty.easy => 'Oson',
        QuizDifficulty.medium => 'O\'rta',
        QuizDifficulty.hard => 'Qiyin',
      };

  Color get color => switch (this) {
        QuizDifficulty.easy => const Color(0xFF10B981),
        QuizDifficulty.medium => const Color(0xFFF59E0B),
        QuizDifficulty.hard => const Color(0xFFEF4444),
      };
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.category,
    this.difficulty = QuizDifficulty.medium,
    this.codeSnippet,
    this.xpReward = 20,
  });

  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final QuizCategory category;
  final QuizDifficulty difficulty;
  final String? codeSnippet;
  final int xpReward;
}
