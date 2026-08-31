// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupModel _$GroupModelFromJson(Map<String, dynamic> json) => GroupModel(
  id: json['id'] as String,
  name: json['name'] as String,
  coursePrice: json['course_price'] as String?,
  mentorName: json['mentor_name'] as String?,
  mentorPhoto: json['mentor_photo'] as String?,
  supportTeacherName: json['support_teacher_name'] as String?,
  supportTeacherPhoto: json['support_teacher_photo'] as String?,
  startDate: json['start_date'] as String?,
  endDate: json['end_date'] as String?,
  isActive: json['is_active'] as bool? ?? true,
  daysOfWeek: json['days'] as String?,
  roomNumber: json['room'] as String?,
);

Map<String, dynamic> _$GroupModelToJson(GroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'course_price': instance.coursePrice,
      'mentor_name': instance.mentorName,
      'mentor_photo': instance.mentorPhoto,
      'support_teacher_name': instance.supportTeacherName,
      'support_teacher_photo': instance.supportTeacherPhoto,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'is_active': instance.isActive,
      'days': instance.daysOfWeek,
      'room': instance.roomNumber,
    };
