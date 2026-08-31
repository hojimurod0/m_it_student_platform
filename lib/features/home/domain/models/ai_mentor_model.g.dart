// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_mentor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiMentorMessage _$AiMentorMessageFromJson(Map<String, dynamic> json) =>
    AiMentorMessage(
      id: json['id'] as String,
      senderName: json['senderName'] as String,
      text: json['text'] as String,
      time: json['time'] as String,
      isUser: json['isUser'] as bool,
      isAi: json['isAi'] as bool? ?? true,
      category:
          $enumDecodeNullable(
            _$AiQueryCategoryEnumMap,
            json['category'],
            unknownValue: AiQueryCategory.general,
          ) ??
          AiQueryCategory.general,
      codeSnippet: json['codeSnippet'] as String?,
      codeLanguage: json['codeLanguage'] as String?,
      followUpPrompts:
          (json['followUpPrompts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      helpfulVote: json['helpfulVote'] as bool?,
    );

Map<String, dynamic> _$AiMentorMessageToJson(AiMentorMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderName': instance.senderName,
      'text': instance.text,
      'time': instance.time,
      'isUser': instance.isUser,
      'isAi': instance.isAi,
      'category': _$AiQueryCategoryEnumMap[instance.category]!,
      'codeSnippet': instance.codeSnippet,
      'codeLanguage': instance.codeLanguage,
      'followUpPrompts': instance.followUpPrompts,
      'helpfulVote': instance.helpfulVote,
    };

const _$AiQueryCategoryEnumMap = {
  AiQueryCategory.flutter: 'flutter',
  AiQueryCategory.dart: 'dart',
  AiQueryCategory.python: 'python',
  AiQueryCategory.web: 'web',
  AiQueryCategory.backend: 'backend',
  AiQueryCategory.git: 'git',
  AiQueryCategory.database: 'database',
  AiQueryCategory.debugging: 'debugging',
  AiQueryCategory.academy: 'academy',
  AiQueryCategory.general: 'general',
};
