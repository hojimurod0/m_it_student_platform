enum NotificationType {
  info,
  grade,
  attendance,
  payment,
  chat,
  homework,
  announcement,
  general,
}

/// Pure Domain Entity: Bildirishnoma (Notification) ob'ekti
class InAppNotification {
  final String id;
  final String title;
  final String body;
  final String createdAt;
  final bool isRead;
  final NotificationType type;
  final String? payload;

  const InAppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.type = NotificationType.info,
    this.payload,
  });

  String get message => body;

  InAppNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? createdAt,
    bool? isRead,
    NotificationType? type,
    String? payload,
  }) {
    return InAppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      payload: payload ?? this.payload,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InAppNotification && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
