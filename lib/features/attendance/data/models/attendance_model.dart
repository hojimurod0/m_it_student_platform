import 'package:json_annotation/json_annotation.dart';
import 'package:m_it_student_platform/features/attendance/domain/entities/attendance.dart';

part 'attendance_model.g.dart';

enum AttendanceTypeModel {
  @JsonValue('faceId')
  faceId,
  @JsonValue('manual')
  manual,
  @JsonValue('qr')
  qr,
}

@JsonSerializable()
class AttendanceRecordModel {
  const AttendanceRecordModel({
    required this.id,
    required this.date,
    this.checkin,
    this.checkout,
    this.type = AttendanceTypeModel.faceId,
    this.groupName,
    this.note,
  });

  final String id;
  final String date;
  final String? checkin;
  final String? checkout;
  @JsonKey(unknownEnumValue: AttendanceTypeModel.faceId, defaultValue: AttendanceTypeModel.faceId)
  final AttendanceTypeModel type;
  @JsonKey(name: 'group_name')
  final String? groupName;
  final String? note;

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    final dateStr = json['date']?.toString() ?? json['lesson_date']?.toString() ?? json['created_at']?.toString() ?? '';
    sanitized['date'] = dateStr;
    sanitized['id'] = (json['id'] ?? (dateStr.isNotEmpty ? dateStr : DateTime.now().millisecondsSinceEpoch.toString())).toString();

    final status = (json['status'] ?? json['attendance_status'] ?? json['status_label'] ?? '').toString().toLowerCase();
    
    if (json['checkin'] != null || json['check_in'] != null || json['time'] != null) {
      sanitized['checkin'] = (json['checkin'] ?? json['check_in'] ?? json['time']).toString();
    } else if (status == 'checkin' || status.contains('present') || status.contains('kelgan') || json['is_present'] == true) {
      sanitized['checkin'] = 'Darsda';
    }

    sanitized['checkout'] = json['checkout']?.toString() ?? json['check_out']?.toString();
    sanitized['group_name'] = json['group_name']?.toString() ?? json['group']?.toString();
    sanitized['note'] = json['note']?.toString() ?? json['status_label']?.toString() ?? (status == 'checkin' ? 'Kelgan' : (json['is_lesson'] == true ? 'Dars' : ''));

    return _$AttendanceRecordModelFromJson(sanitized);
  }

  Map<String, dynamic> toJson() => _$AttendanceRecordModelToJson(this);

  AttendanceRecord toEntity() => AttendanceRecord(
        id: id,
        date: date,
        checkin: checkin,
        checkout: checkout,
        type: switch (type) {
          AttendanceTypeModel.faceId => AttendanceType.faceId,
          AttendanceTypeModel.manual => AttendanceType.manual,
          AttendanceTypeModel.qr => AttendanceType.qr,
        },
        groupName: groupName,
        note: note,
      );

  factory AttendanceRecordModel.fromEntity(AttendanceRecord entity) => AttendanceRecordModel(
        id: entity.id,
        date: entity.date,
        checkin: entity.checkin,
        checkout: entity.checkout,
        type: switch (entity.type) {
          AttendanceType.faceId => AttendanceTypeModel.faceId,
          AttendanceType.manual => AttendanceTypeModel.manual,
          AttendanceType.qr => AttendanceTypeModel.qr,
        },
        groupName: entity.groupName,
        note: entity.note,
      );
}
