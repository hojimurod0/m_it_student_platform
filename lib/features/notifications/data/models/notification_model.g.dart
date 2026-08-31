// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: json['created_at'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      type:
          $enumDecodeNullable(
            _$NotificationTypeModelEnumMap,
            json['type'],
            unknownValue: NotificationTypeModel.info,
          ) ??
          NotificationTypeModel.info,
      payload: json['payload'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'created_at': instance.createdAt,
      'is_read': instance.isRead,
      'type': _$NotificationTypeModelEnumMap[instance.type]!,
      'payload': instance.payload,
    };

const _$NotificationTypeModelEnumMap = {
  NotificationTypeModel.info: 'info',
  NotificationTypeModel.grade: 'grade',
  NotificationTypeModel.attendance: 'attendance',
  NotificationTypeModel.payment: 'payment',
  NotificationTypeModel.chat: 'chat',
  NotificationTypeModel.homework: 'homework',
  NotificationTypeModel.announcement: 'announcement',
  NotificationTypeModel.general: 'general',
};
