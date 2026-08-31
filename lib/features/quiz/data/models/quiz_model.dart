import 'package:json_annotation/json_annotation.dart';
import 'package:m_it_student_platform/features/quiz/domain/entities/quiz.dart';

part 'quiz_model.g.dart';

enum QuizCategoryModel {
  @JsonValue('flutter')
  flutter,
  @JsonValue('dart')
  dart,
  @JsonValue('python')
  python,
  @JsonValue('frontend')
  frontend,
  @JsonValue('git')
  git,
  @JsonValue('algorithms')
  algorithms,
  @JsonValue('backend')
  backend,
  @JsonValue('general')
  general,
}

enum QuizDifficultyModel {
  @JsonValue('easy')
  easy,
  @JsonValue('medium')
  medium,
  @JsonValue('hard')
  hard,
}

@JsonSerializable()
class QuizQuestionModel {
  const QuizQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    this.correctIndex = 0,
    this.explanation = '',
    this.category = QuizCategoryModel.flutter,
    this.difficulty = QuizDifficultyModel.medium,
    this.coinReward = 10,
    this.xpReward = 10,
    this.codeSnippet,
  });

  final String id;
  final String question;
  final List<String> options;
  @JsonKey(name: 'correct_index', defaultValue: 0)
  final int correctIndex;
  @JsonKey(defaultValue: '')
  final String explanation;
  @JsonKey(unknownEnumValue: QuizCategoryModel.flutter, defaultValue: QuizCategoryModel.flutter)
  final QuizCategoryModel category;
  @JsonKey(unknownEnumValue: QuizDifficultyModel.medium, defaultValue: QuizDifficultyModel.medium)
  final QuizDifficultyModel difficulty;
  @JsonKey(name: 'coin_reward', defaultValue: 10)
  final int coinReward;
  @JsonKey(name: 'xp_reward', defaultValue: 10)
  final int xpReward;
  @JsonKey(name: 'code_snippet')
  final String? codeSnippet;

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuizQuestionModelToJson(this);

  QuizQuestion toEntity() => QuizQuestion(
        id: id,
        question: question,
        options: options,
        correctIndex: correctIndex,
        explanation: explanation,
        category: switch (category) {
          QuizCategoryModel.flutter => QuizCategory.flutter,
          QuizCategoryModel.dart => QuizCategory.dart,
          QuizCategoryModel.python => QuizCategory.python,
          QuizCategoryModel.frontend => QuizCategory.frontend,
          QuizCategoryModel.git => QuizCategory.git,
          QuizCategoryModel.algorithms => QuizCategory.algorithms,
          QuizCategoryModel.backend => QuizCategory.backend,
          QuizCategoryModel.general => QuizCategory.general,
        },
        difficulty: switch (difficulty) {
          QuizDifficultyModel.easy => QuizDifficulty.easy,
          QuizDifficultyModel.medium => QuizDifficulty.medium,
          QuizDifficultyModel.hard => QuizDifficulty.hard,
        },
        coinReward: coinReward,
        xpReward: xpReward,
        codeSnippet: codeSnippet,
      );

  factory QuizQuestionModel.fromEntity(QuizQuestion entity) => QuizQuestionModel(
        id: entity.id,
        question: entity.question,
        options: entity.options,
        correctIndex: entity.correctIndex,
        explanation: entity.explanation,
        category: switch (entity.category) {
          QuizCategory.flutter => QuizCategoryModel.flutter,
          QuizCategory.dart => QuizCategoryModel.dart,
          QuizCategory.python => QuizCategoryModel.python,
          QuizCategory.frontend => QuizCategoryModel.frontend,
          QuizCategory.git => QuizCategoryModel.git,
          QuizCategory.algorithms => QuizCategoryModel.algorithms,
          QuizCategory.backend => QuizCategoryModel.backend,
          QuizCategory.general => QuizCategoryModel.general,
        },
        difficulty: switch (entity.difficulty) {
          QuizDifficulty.easy => QuizDifficultyModel.easy,
          QuizDifficulty.medium => QuizDifficultyModel.medium,
          QuizDifficulty.hard => QuizDifficultyModel.hard,
        },
        coinReward: entity.coinReward,
        xpReward: entity.xpReward,
        codeSnippet: entity.codeSnippet,
      );
}
