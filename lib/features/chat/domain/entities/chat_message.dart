enum SenderRole {
  student,
  mentor,
  support,
}

/// Pure Domain Entity: Chat xabar ob'ekti
class ChatMessage {
  final String id;
  final String text;
  final String senderName;
  final String sentAt;
  final String? senderId;
  final String? attachmentUrl;
  final String? attachmentType;
  final bool isMe;
  final String? senderAvatar;
  final SenderRole senderRole;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.senderName,
    required this.sentAt,
    this.senderId,
    this.attachmentUrl,
    this.attachmentType,
    this.isMe = false,
    this.senderAvatar,
    this.senderRole = SenderRole.student,
  });

  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;

  ChatMessage copyWith({
    String? id,
    String? text,
    String? senderName,
    String? sentAt,
    String? senderId,
    String? attachmentUrl,
    String? attachmentType,
    bool? isMe,
    String? senderAvatar,
    SenderRole? senderRole,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      senderName: senderName ?? this.senderName,
      sentAt: sentAt ?? this.sentAt,
      senderId: senderId ?? this.senderId,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentType: attachmentType ?? this.attachmentType,
      isMe: isMe ?? this.isMe,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      senderRole: senderRole ?? this.senderRole,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
