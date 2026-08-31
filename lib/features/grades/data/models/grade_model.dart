import 'package:json_annotation/json_annotation.dart';
import 'package:m_it_student_platform/features/grades/domain/entities/grade.dart';

part 'grade_model.g.dart';

@JsonSerializable()
class GradeItemModel {
  const GradeItemModel({
    required this.id,
    required this.lessonTitle,
    required this.score,
    required this.maxScore,
    required this.date,
    this.coins = 0,
    this.mentorComment,
    this.groupName,
  });

  final String id;
  @JsonKey(name: 'lesson_title', defaultValue: 'Dars')
  final String lessonTitle;
  @JsonKey(defaultValue: 0)
  final int score;
  @JsonKey(name: 'max_score', defaultValue: 100)
  final int maxScore;
  @JsonKey(defaultValue: '')
  final String date;
  @JsonKey(defaultValue: 0)
  final int coins;
  @JsonKey(name: 'comment')
  final String? mentorComment;
  @JsonKey(name: 'group_name')
  final String? groupName;

  factory GradeItemModel.fromJson(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    sanitized['id'] = (json['id'] ?? '').toString();
    sanitized['lesson_title'] = json['lesson_title']?.toString() ?? json['title']?.toString() ?? json['lesson_name']?.toString() ?? 'Amaliy Dars';
    sanitized['score'] = (json['score'] as num?)?.toInt() ?? (json['grade'] as num?)?.toInt() ?? (json['points'] as num?)?.toInt() ?? 0;
    sanitized['max_score'] = (json['max_score'] as num?)?.toInt() ?? (json['total_score'] as num?)?.toInt() ?? 100;
    sanitized['date'] = json['date']?.toString() ?? json['lesson_date']?.toString() ?? json['created_at']?.toString() ?? '';
    sanitized['coins'] = (json['coins'] as num?)?.toInt() ?? (json['coin'] as num?)?.toInt() ?? 0;
    sanitized['comment'] = json['comment']?.toString() ?? json['mentor_comment']?.toString() ?? json['feedback']?.toString();
    sanitized['group_name'] = json['group_name']?.toString() ?? json['group']?.toString();
    return _$GradeItemModelFromJson(sanitized);
  }

  Map<String, dynamic> toJson() => _$GradeItemModelToJson(this);

  GradeItem toEntity() => GradeItem(
        id: id,
        lessonTitle: lessonTitle,
        score: score,
        maxScore: maxScore,
        date: date,
        coins: coins,
        mentorComment: mentorComment,
        groupName: groupName,
      );

  factory GradeItemModel.fromEntity(GradeItem entity) => GradeItemModel(
        id: entity.id,
        lessonTitle: entity.lessonTitle,
        score: entity.score,
        maxScore: entity.maxScore,
        date: entity.date,
        coins: entity.coins,
        mentorComment: entity.mentorComment,
        groupName: entity.groupName,
      );
}
