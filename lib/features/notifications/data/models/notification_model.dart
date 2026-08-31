import 'package:json_annotation/json_annotation.dart';
import 'package:m_it_student_platform/features/notifications/domain/entities/notification.dart';

part 'notification_model.g.dart';

enum NotificationTypeModel {
  @JsonValue('info')
  info,
  @JsonValue('grade')
  grade,
  @JsonValue('attendance')
  attendance,
  @JsonValue('payment')
  payment,
  @JsonValue('chat')
  chat,
  @JsonValue('homework')
  homework,
  @JsonValue('announcement')
  announcement,
  @JsonValue('general')
  general,
}

@JsonSerializable()
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.type = NotificationTypeModel.info,
    this.payload,
  });

  final String id;
  final String title;
  final String body;
  @JsonKey(name: 'created_at', defaultValue: '')
  final String createdAt;
  @JsonKey(name: 'is_read', defaultValue: false)
  final bool isRead;
  @JsonKey(unknownEnumValue: NotificationTypeModel.info, defaultValue: NotificationTypeModel.info)
  final NotificationTypeModel type;
  final String? payload;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    sanitized['id'] = (json['id'] ?? '').toString();
    sanitized['title'] = json['title']?.toString() ?? json['name']?.toString() ?? 'Bildirishnoma';
    sanitized['body'] = json['body']?.toString() ?? json['message']?.toString() ?? json['content']?.toString() ?? '';
    sanitized['created_at'] = json['created_at']?.toString() ?? json['date']?.toString() ?? '';
    sanitized['is_read'] = json['is_read'] == true || json['isRead'] == true || json['read'] == true;
    return _$NotificationModelFromJson(sanitized);
  }

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  InAppNotification toEntity() => InAppNotification(
        id: id,
        title: title,
        body: body,
        createdAt: createdAt,
        isRead: isRead,
        type: switch (type) {
          NotificationTypeModel.info => NotificationType.info,
          NotificationTypeModel.grade => NotificationType.grade,
          NotificationTypeModel.attendance => NotificationType.attendance,
          NotificationTypeModel.payment => NotificationType.payment,
          NotificationTypeModel.chat => NotificationType.chat,
          NotificationTypeModel.homework => NotificationType.homework,
          NotificationTypeModel.announcement => NotificationType.announcement,
          NotificationTypeModel.general => NotificationType.general,
        },
        payload: payload,
      );

  factory NotificationModel.fromEntity(InAppNotification entity) => NotificationModel(
        id: entity.id,
        title: entity.title,
        body: entity.body,
        createdAt: entity.createdAt,
        isRead: entity.isRead,
        type: switch (entity.type) {
          NotificationType.info => NotificationTypeModel.info,
          NotificationType.grade => NotificationTypeModel.grade,
          NotificationType.attendance => NotificationTypeModel.attendance,
          NotificationType.payment => NotificationTypeModel.payment,
          NotificationType.chat => NotificationTypeModel.chat,
          NotificationType.homework => NotificationTypeModel.homework,
          NotificationType.announcement => NotificationTypeModel.announcement,
          NotificationType.general => NotificationTypeModel.general,
        },
        payload: entity.payload,
      );
}
