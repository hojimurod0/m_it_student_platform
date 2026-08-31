import 'package:json_annotation/json_annotation.dart';
import 'package:m_it_student_platform/features/chat/domain/entities/chat_message.dart';

part 'chat_message_model.g.dart';

enum SenderRoleModel {
  @JsonValue('student')
  student,
  @JsonValue('mentor')
  mentor,
  @JsonValue('support')
  support,
}

@JsonSerializable()
class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.senderName,
    required this.sentAt,
    this.senderId,
    this.attachmentUrl,
    this.attachmentType,
    this.isMe = false,
    this.senderAvatar,
    this.senderRole = SenderRoleModel.student,
  });

  final String id;
  final String text;
  @JsonKey(name: 'sender_name', defaultValue: 'User')
  final String senderName;
  @JsonKey(name: 'sent_at', defaultValue: '')
  final String sentAt;
  @JsonKey(name: 'sender_id')
  final String? senderId;
  @JsonKey(name: 'attachment_url')
  final String? attachmentUrl;
  @JsonKey(name: 'attachment_type')
  final String? attachmentType;
  @JsonKey(defaultValue: false)
  final bool isMe;
  @JsonKey(name: 'sender_avatar')
  final String? senderAvatar;
  @JsonKey(unknownEnumValue: SenderRoleModel.student, defaultValue: SenderRoleModel.student)
  final SenderRoleModel senderRole;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => _$ChatMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);

  ChatMessage toEntity() => ChatMessage(
        id: id,
        text: text,
        senderName: senderName,
        sentAt: sentAt,
        senderId: senderId,
        attachmentUrl: attachmentUrl,
        attachmentType: attachmentType,
        isMe: isMe,
        senderAvatar: senderAvatar,
        senderRole: switch (senderRole) {
          SenderRoleModel.student => SenderRole.student,
          SenderRoleModel.mentor => SenderRole.mentor,
          SenderRoleModel.support => SenderRole.support,
        },
      );

  factory ChatMessageModel.fromEntity(ChatMessage entity) => ChatMessageModel(
        id: entity.id,
        text: entity.text,
        senderName: entity.senderName,
        sentAt: entity.sentAt,
        senderId: entity.senderId,
        attachmentUrl: entity.attachmentUrl,
        attachmentType: entity.attachmentType,
        isMe: entity.isMe,
        senderAvatar: entity.senderAvatar,
        senderRole: switch (entity.senderRole) {
          SenderRole.student => SenderRoleModel.student,
          SenderRole.mentor => SenderRoleModel.mentor,
          SenderRole.support => SenderRoleModel.support,
        },
      );
}
