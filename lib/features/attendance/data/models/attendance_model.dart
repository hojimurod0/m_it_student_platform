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
    this.isPresent = true,
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
  @JsonKey(name: 'is_present', defaultValue: true)
  final bool isPresent;

  static String? _formatTime(dynamic val, [String? fallback]) {
    if (val == null) return fallback;
    final str = val.toString().trim();
    if (str.isEmpty || str == 'null') return fallback;

    if (str.contains('T')) {
      try {
        final dt = DateTime.parse(str).toLocal();
        final h = dt.hour.toString().padLeft(2, '0');
        final m = dt.minute.toString().padLeft(2, '0');
        return '$h:$m';
      } catch (_) {}
    }

    final parts = str.split(':');
    if (parts.length >= 2) {
      final h = parts[0].padLeft(2, '0');
      final m = parts[1].padLeft(2, '0');
      return '$h:$m';
    }

    return str;
  }

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    final dateStr = json['date']?.toString() ??
        json['lesson_date']?.toString() ??
        json['created_at']?.toString() ??
        json['day']?.toString() ??
        '';
    sanitized['date'] = dateStr;
    sanitized['id'] = (json['id'] ??
            (dateStr.isNotEmpty
                ? dateStr
                : DateTime.now().millisecondsSinceEpoch.toString()))
        .toString();

    final status = (json['status'] ??
            json['attendance_status'] ??
            json['status_label'] ??
            '')
        .toString()
        .toLowerCase();

    final isAbsentDirect = json['is_present'] == false ||
        json['present'] == false ||
        json['attended'] == false ||
        json['has_attended'] == false ||
        status == 'absent' ||
        status == 'kelmagan' ||
        status == 'sababsiz' ||
        status.contains('kelmagan') ||
        status.contains('absent');

    final isPresentDirect = !isAbsentDirect &&
        (json['is_present'] == true ||
            json['present'] == true ||
            json['attended'] == true ||
            json['has_attended'] == true ||
            status == 'present' ||
            status == 'kelgan' ||
            status == 'bor' ||
            status == 'checkin' ||
            status.contains('kelgan') ||
            (json['checkin'] != null && json['checkin'].toString().isNotEmpty && json['checkin'] != 'null') ||
            (json['check_in'] != null && json['check_in'].toString().isNotEmpty && json['check_in'] != 'null'));

    sanitized['is_present'] = isPresentDirect;

    final rawCheckin = json['checkin'] ??
        json['check_in'] ??
        json['entry_time'] ??
        json['enter_time'] ??
        json['come_time'] ??
        json['time'] ??
        json['lesson_start'] ??
        json['start_time'];

    final rawCheckout = json['checkout'] ??
        json['check_out'] ??
        json['exit_time'] ??
        json['leave_time'] ??
        json['left_time'] ??
        json['lesson_end'] ??
        json['end_time'];

    if (rawCheckin != null && rawCheckin.toString().isNotEmpty && rawCheckin.toString() != 'null') {
      sanitized['checkin'] = _formatTime(rawCheckin);
    } else if (isPresentDirect) {
      sanitized['checkin'] = _formatTime(json['default_start'], '11:00');
    } else {
      sanitized['checkin'] = null;
    }

    if (rawCheckout != null && rawCheckout.toString().isNotEmpty && rawCheckout.toString() != 'null') {
      sanitized['checkout'] = _formatTime(rawCheckout);
    } else if (isPresentDirect) {
      sanitized['checkout'] = _formatTime(json['default_end'], '14:00');
    } else {
      sanitized['checkout'] = null;
    }

    sanitized['group_name'] = json['group_name']?.toString() ??
        json['group']?.toString() ??
        json['default_group_name']?.toString();
    sanitized['note'] = json['note']?.toString() ??
        json['status_label']?.toString() ??
        (isPresentDirect ? 'Kelgan' : 'Kelmagan');

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
        isPresent: isPresent,
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
        isPresent: entity.isPresent,
      );
}
