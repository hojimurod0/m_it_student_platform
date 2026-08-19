enum AnnouncementType {
  exam,
  payment,
  event,
  general,
  assignment,
}

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.date,
    required this.time,
    required this.author,
    this.isUrgent = false,
    this.actionLabel,
    this.actionUrl,
  });

  final String id;
  final String title;
  final String message;
  final AnnouncementType type;
  final String date;
  final String time;
  final String author;
  final bool isUrgent;
  final String? actionLabel;
  final String? actionUrl;
}
