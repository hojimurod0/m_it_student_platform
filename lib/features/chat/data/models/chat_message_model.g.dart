// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageModel _$ChatMessageModelFromJson(Map<String, dynamic> json) =>
    ChatMessageModel(
      id: json['id'] as String,
      text: json['text'] as String,
      senderName: json['sender_name'] as String? ?? 'User',
      sentAt: json['sent_at'] as String? ?? '',
      senderId: json['sender_id'] as String?,
      attachmentUrl: json['attachment_url'] as String?,
      attachmentType: json['attachment_type'] as String?,
      isMe: json['isMe'] as bool? ?? false,
      senderAvatar: json['sender_avatar'] as String?,
      senderRole:
          $enumDecodeNullable(
            _$SenderRoleModelEnumMap,
            json['senderRole'],
            unknownValue: SenderRoleModel.student,
          ) ??
          SenderRoleModel.student,
    );

Map<String, dynamic> _$ChatMessageModelToJson(ChatMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'sender_name': instance.senderName,
      'sent_at': instance.sentAt,
      'sender_id': instance.senderId,
      'attachment_url': instance.attachmentUrl,
      'attachment_type': instance.attachmentType,
      'isMe': instance.isMe,
      'sender_avatar': instance.senderAvatar,
      'senderRole': _$SenderRoleModelEnumMap[instance.senderRole]!,
    };

const _$SenderRoleModelEnumMap = {
  SenderRoleModel.student: 'student',
  SenderRoleModel.mentor: 'mentor',
  SenderRoleModel.support: 'support',
};
