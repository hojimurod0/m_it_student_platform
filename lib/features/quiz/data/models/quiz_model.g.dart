// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizQuestionModel _$QuizQuestionModelFromJson(Map<String, dynamic> json) =>
    QuizQuestionModel(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctIndex: (json['correct_index'] as num?)?.toInt() ?? 0,
      explanation: json['explanation'] as String? ?? '',
      category:
          $enumDecodeNullable(
            _$QuizCategoryModelEnumMap,
            json['category'],
            unknownValue: QuizCategoryModel.flutter,
          ) ??
          QuizCategoryModel.flutter,
      difficulty:
          $enumDecodeNullable(
            _$QuizDifficultyModelEnumMap,
            json['difficulty'],
            unknownValue: QuizDifficultyModel.medium,
          ) ??
          QuizDifficultyModel.medium,
      coinReward: (json['coin_reward'] as num?)?.toInt() ?? 10,
      xpReward: (json['xp_reward'] as num?)?.toInt() ?? 10,
      codeSnippet: json['code_snippet'] as String?,
    );

Map<String, dynamic> _$QuizQuestionModelToJson(QuizQuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'options': instance.options,
      'correct_index': instance.correctIndex,
      'explanation': instance.explanation,
      'category': _$QuizCategoryModelEnumMap[instance.category]!,
      'difficulty': _$QuizDifficultyModelEnumMap[instance.difficulty]!,
      'coin_reward': instance.coinReward,
      'xp_reward': instance.xpReward,
      'code_snippet': instance.codeSnippet,
    };

const _$QuizCategoryModelEnumMap = {
  QuizCategoryModel.flutter: 'flutter',
  QuizCategoryModel.dart: 'dart',
  QuizCategoryModel.python: 'python',
  QuizCategoryModel.frontend: 'frontend',
  QuizCategoryModel.git: 'git',
  QuizCategoryModel.algorithms: 'algorithms',
  QuizCategoryModel.backend: 'backend',
  QuizCategoryModel.general: 'general',
};

const _$QuizDifficultyModelEnumMap = {
  QuizDifficultyModel.easy: 'easy',
  QuizDifficultyModel.medium: 'medium',
  QuizDifficultyModel.hard: 'hard',
};
