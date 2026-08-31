import 'package:json_annotation/json_annotation.dart';
import 'package:m_it_student_platform/features/homework/domain/entities/homework.dart';

part 'homework_model.g.dart';

enum HomeworkStatusModel {
  @JsonValue('pending')
  pending,
  @JsonValue('submitted')
  submitted,
  @JsonValue('reviewed')
  reviewed,
}

@JsonSerializable()
class HomeworkItemModel {
  const HomeworkItemModel({
    required this.id,
    required this.title,
    required this.course,
    required this.deadline,
    required this.description,
    this.status = HomeworkStatusModel.pending,
    this.githubRepoUrl,
    this.score,
    this.mentorFeedback,
  });

  final String id;
  final String title;
  final String course;
  final String deadline;
  final String description;
  @JsonKey(unknownEnumValue: HomeworkStatusModel.pending, defaultValue: HomeworkStatusModel.pending)
  final HomeworkStatusModel status;
  @JsonKey(name: 'github_url')
  final String? githubRepoUrl;
  final int? score;
  @JsonKey(name: 'mentor_feedback')
  final String? mentorFeedback;

  factory HomeworkItemModel.fromJson(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    sanitized['id'] = (json['id'] ?? '').toString();
    sanitized['title'] = json['title']?.toString() ?? json['name']?.toString() ?? 'Vazifa';
    sanitized['course'] = json['course']?.toString() ?? json['course_name']?.toString() ?? json['group_name']?.toString() ?? 'Back end 05';
    sanitized['deadline'] = json['deadline']?.toString() ?? json['due_date']?.toString() ?? 'Bugun';
    sanitized['description'] = json['description']?.toString() ?? 'Amaliy topshiriq va mashg\'ulotlar';
    sanitized['github_url'] = json['github_url']?.toString() ?? json['githubRepoUrl']?.toString() ?? json['link']?.toString();
    sanitized['mentor_feedback'] = json['mentor_feedback']?.toString() ?? json['feedback']?.toString() ?? json['comment']?.toString();
    sanitized['score'] = (json['score'] as num?)?.toInt() ?? (json['grade'] as num?)?.toInt();

    if (sanitized['status'] == null) {
      if (json['is_reviewed'] == true || json['score'] != null) {
        sanitized['status'] = 'reviewed';
      } else if (json['is_submitted'] == true || json['status'] == 'submitted') {
        sanitized['status'] = 'submitted';
      } else {
        sanitized['status'] = 'pending';
      }
    }
    return _$HomeworkItemModelFromJson(sanitized);
  }

  Map<String, dynamic> toJson() => _$HomeworkItemModelToJson(this);

  HomeworkItem toEntity() => HomeworkItem(
        id: id,
        title: title,
        course: course,
        deadline: deadline,
        description: description,
        status: switch (status) {
          HomeworkStatusModel.pending => HomeworkStatus.pending,
          HomeworkStatusModel.submitted => HomeworkStatus.submitted,
          HomeworkStatusModel.reviewed => HomeworkStatus.reviewed,
        },
        githubRepoUrl: githubRepoUrl,
        score: score,
        mentorFeedback: mentorFeedback,
      );

  factory HomeworkItemModel.fromEntity(HomeworkItem entity) => HomeworkItemModel(
        id: entity.id,
        title: entity.title,
        course: entity.course,
        deadline: entity.deadline,
        description: entity.description,
        status: switch (entity.status) {
          HomeworkStatus.pending => HomeworkStatusModel.pending,
          HomeworkStatus.submitted => HomeworkStatusModel.submitted,
          HomeworkStatus.reviewed => HomeworkStatusModel.reviewed,
        },
        githubRepoUrl: entity.githubRepoUrl,
        score: entity.score,
        mentorFeedback: entity.mentorFeedback,
      );
}
