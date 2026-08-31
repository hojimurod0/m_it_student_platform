// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Announcement _$AnnouncementFromJson(Map<String, dynamic> json) => Announcement(
  id: json['id'] as String,
  title: json['title'] as String,
  message: json['message'] as String,
  type:
      $enumDecodeNullable(
        _$AnnouncementTypeEnumMap,
        json['type'],
        unknownValue: AnnouncementType.general,
      ) ??
      AnnouncementType.general,
  date: json['date'] as String,
  time: json['time'] as String,
  author: json['author'] as String,
  isUrgent: json['isUrgent'] as bool? ?? false,
  actionLabel: json['actionLabel'] as String?,
  actionUrl: json['actionUrl'] as String?,
);

Map<String, dynamic> _$AnnouncementToJson(Announcement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'type': _$AnnouncementTypeEnumMap[instance.type]!,
      'date': instance.date,
      'time': instance.time,
      'author': instance.author,
      'isUrgent': instance.isUrgent,
      'actionLabel': instance.actionLabel,
      'actionUrl': instance.actionUrl,
    };

const _$AnnouncementTypeEnumMap = {
  AnnouncementType.exam: 'exam',
  AnnouncementType.payment: 'payment',
  AnnouncementType.event: 'event',
  AnnouncementType.general: 'general',
  AnnouncementType.assignment: 'assignment',
};
