import 'package:json_annotation/json_annotation.dart';

part 'attendance_model.g.dart';

@JsonSerializable()
class AttendanceRecord {
  const AttendanceRecord({
    required this.subject,
    required this.attended,
    required this.total,
    required this.percentage,
    this.date,
    this.status,
  });

  final String subject;
  final int attended;
  final int total;
  final int percentage;
  final String? date;
  final String? status;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    sanitized['subject'] = json['subject']?.toString() ??
        json['subject_name']?.toString() ??
        json['group_name']?.toString() ??
        json['lesson_title']?.toString() ??
        json['group']?.toString() ??
        'Dars davomati';

    final attended = (json['attended'] as num?)?.toInt() ??
        (json['present_count'] as num?)?.toInt() ??
        (json['attended_days'] as num?)?.toInt() ??
        (json['is_present'] == true ? 1 : 0);
    sanitized['attended'] = attended;

    final total = (json['total'] as num?)?.toInt() ??
        (json['total_count'] as num?)?.toInt() ??
        (json['total_days'] as num?)?.toInt() ??
        1;
    sanitized['total'] = total > 0 ? total : 1;

    if (json['percentage'] != null) {
      sanitized['percentage'] = (json['percentage'] as num).toInt();
    } else if (json['attendance_percentage'] != null) {
      sanitized['percentage'] = (json['attendance_percentage'] as num).toInt();
    } else {
      sanitized['percentage'] = ((attended / (total > 0 ? total : 1)) * 100).round().clamp(0, 100);
    }

    sanitized['date'] = json['date']?.toString() ??
        json['lesson_date']?.toString() ??
        json['created_at']?.toString();
    sanitized['status'] = json['status']?.toString() ??
        json['attendance_status']?.toString();

    return _$AttendanceRecordFromJson(sanitized);
  }

  Map<String, dynamic> toJson() => _$AttendanceRecordToJson(this);
}
