import 'package:json_annotation/json_annotation.dart';

part 'grade_model.g.dart';

@JsonSerializable()
class GradeItem {
  const GradeItem({
    required this.taskName,
    required this.moduleName,
    required this.score,
    required this.gradeLetter,
    required this.date,
  });

  final String taskName;
  final String moduleName;
  final int score;
  final String gradeLetter;
  final String date;

  factory GradeItem.fromJson(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    sanitized['taskName'] = json['taskName']?.toString() ??
        json['task_name']?.toString() ??
        json['lesson_title']?.toString() ??
        json['title']?.toString() ??
        json['lesson_name']?.toString() ??
        'Amaliy topshiriq';
    sanitized['moduleName'] = json['moduleName']?.toString() ??
        json['module_name']?.toString() ??
        json['group_name']?.toString() ??
        json['course_name']?.toString() ??
        json['group']?.toString() ??
        'M-IT Academy';
    final rawScore = (json['score'] as num?)?.toInt() ??
        (json['grade'] as num?)?.toInt() ??
        (json['points'] as num?)?.toInt() ??
        (json['ball'] as num?)?.toInt() ??
        85;
    sanitized['score'] = rawScore;
    
    if (json['gradeLetter'] != null) {
      sanitized['gradeLetter'] = json['gradeLetter'].toString();
    } else {
      if (rawScore >= 95) {
        sanitized['gradeLetter'] = 'A+';
      } else if (rawScore >= 85) {
        sanitized['gradeLetter'] = 'A';
      } else if (rawScore >= 75) {
        sanitized['gradeLetter'] = 'B';
      } else if (rawScore >= 60) {
        sanitized['gradeLetter'] = 'C';
      } else {
        sanitized['gradeLetter'] = 'F';
      }
    }
    
    sanitized['date'] = json['date']?.toString() ??
        json['lesson_date']?.toString() ??
        json['created_at']?.toString() ??
        json['date_str']?.toString() ??
        'Yaqinda';

    return _$GradeItemFromJson(sanitized);
  }

  Map<String, dynamic> toJson() => _$GradeItemToJson(this);
}
