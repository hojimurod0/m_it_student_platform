import 'package:json_annotation/json_annotation.dart';

part 'announcement_model.g.dart';

enum AnnouncementType {
  @JsonValue('exam')
  exam,
  @JsonValue('payment')
  payment,
  @JsonValue('event')
  event,
  @JsonValue('general')
  general,
  @JsonValue('assignment')
  assignment,
}

@JsonSerializable()
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
  @JsonKey(unknownEnumValue: AnnouncementType.general, defaultValue: AnnouncementType.general)
  final AnnouncementType type;
  final String date;
  final String time;
  final String author;
  @JsonKey(defaultValue: false)
  final bool isUrgent;
  final String? actionLabel;
  final String? actionUrl;

  factory Announcement.fromJson(Map<String, dynamic> json) => _$AnnouncementFromJson(json);

  Map<String, dynamic> toJson() => _$AnnouncementToJson(this);
}
