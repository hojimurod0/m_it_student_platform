// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GradeItemModel _$GradeItemModelFromJson(Map<String, dynamic> json) =>
    GradeItemModel(
      id: json['id'] as String,
      lessonTitle: json['lesson_title'] as String? ?? 'Dars',
      score: (json['score'] as num?)?.toInt() ?? 0,
      maxScore: (json['max_score'] as num?)?.toInt() ?? 100,
      date: json['date'] as String? ?? '',
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      mentorComment: json['comment'] as String?,
      groupName: json['group_name'] as String?,
    );

Map<String, dynamic> _$GradeItemModelToJson(GradeItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lesson_title': instance.lessonTitle,
      'score': instance.score,
      'max_score': instance.maxScore,
      'date': instance.date,
      'coins': instance.coins,
      'comment': instance.mentorComment,
      'group_name': instance.groupName,
    };
