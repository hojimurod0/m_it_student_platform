// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
      'lesson': instance.lessonId,
      'lesson_title': instance.lessonTitle,
      'attachment_url': instance.attachmentUrl,
    };

const _$HomeworkStatusModelEnumMap = {
  HomeworkStatusModel.pending: 'pending',
  HomeworkStatusModel.submitted: 'submitted',
  HomeworkStatusModel.reviewed: 'reviewed',
};
