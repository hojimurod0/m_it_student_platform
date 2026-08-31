// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GradeItem _$GradeItemFromJson(Map<String, dynamic> json) => GradeItem(
  taskName: json['taskName'] as String,
  moduleName: json['moduleName'] as String,
  score: (json['score'] as num).toInt(),
  gradeLetter: json['gradeLetter'] as String,
  date: json['date'] as String,
);

Map<String, dynamic> _$GradeItemToJson(GradeItem instance) => <String, dynamic>{
  'taskName': instance.taskName,
  'moduleName': instance.moduleName,
  'score': instance.score,
  'gradeLetter': instance.gradeLetter,
  'date': instance.date,
};
