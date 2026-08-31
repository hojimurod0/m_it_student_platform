// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) =>
    AttendanceRecord(
      subject: json['subject'] as String,
      attended: (json['attended'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      percentage: (json['percentage'] as num).toInt(),
      date: json['date'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$AttendanceRecordToJson(AttendanceRecord instance) =>
    <String, dynamic>{
      'subject': instance.subject,
      'attended': instance.attended,
      'total': instance.total,
      'percentage': instance.percentage,
      'date': instance.date,
      'status': instance.status,
    };
