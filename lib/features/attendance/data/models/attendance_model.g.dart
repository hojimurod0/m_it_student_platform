// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceRecordModel _$AttendanceRecordModelFromJson(
  Map<String, dynamic> json,
) => AttendanceRecordModel(
  id: json['id'] as String,
  date: json['date'] as String,
  checkin: json['checkin'] as String?,
  checkout: json['checkout'] as String?,
  type:
      $enumDecodeNullable(
        _$AttendanceTypeModelEnumMap,
        json['type'],
        unknownValue: AttendanceTypeModel.faceId,
      ) ??
      AttendanceTypeModel.faceId,
  groupName: json['group_name'] as String?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$AttendanceRecordModelToJson(
  AttendanceRecordModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date,
  'checkin': instance.checkin,
  'checkout': instance.checkout,
  'type': _$AttendanceTypeModelEnumMap[instance.type]!,
  'group_name': instance.groupName,
  'note': instance.note,
};

const _$AttendanceTypeModelEnumMap = {
  AttendanceTypeModel.faceId: 'faceId',
  AttendanceTypeModel.manual: 'manual',
  AttendanceTypeModel.qr: 'qr',
};
