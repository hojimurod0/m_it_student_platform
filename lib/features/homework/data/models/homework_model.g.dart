// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeworkItemModel _$HomeworkItemModelFromJson(Map<String, dynamic> json) =>
    HomeworkItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      course: json['course'] as String,
      deadline: json['deadline'] as String,
      description: json['description'] as String,
      status:
          $enumDecodeNullable(
            _$HomeworkStatusModelEnumMap,
            json['status'],
            unknownValue: HomeworkStatusModel.pending,
          ) ??
          HomeworkStatusModel.pending,
      githubRepoUrl: json['github_url'] as String?,
      score: (json['score'] as num?)?.toInt(),
      mentorFeedback: json['mentor_feedback'] as String?,
    );

Map<String, dynamic> _$HomeworkItemModelToJson(HomeworkItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'course': instance.course,
      'deadline': instance.deadline,
      'description': instance.description,
      'status': _$HomeworkStatusModelEnumMap[instance.status]!,
      'github_url': instance.githubRepoUrl,
      'score': instance.score,
      'mentor_feedback': instance.mentorFeedback,
    };

const _$HomeworkStatusModelEnumMap = {
  HomeworkStatusModel.pending: 'pending',
  HomeworkStatusModel.submitted: 'submitted',
  HomeworkStatusModel.reviewed: 'reviewed',
};
