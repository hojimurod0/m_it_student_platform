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

@JsonSerializable(createFactory: false)
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
    this.lessonId,
    this.lessonTitle,
    this.attachmentUrl,
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
  @JsonKey(name: 'lesson')
  final String? lessonId;
  @JsonKey(name: 'lesson_title')
  final String? lessonTitle;
  @JsonKey(name: 'attachment_url')
  final String? attachmentUrl;

  factory HomeworkItemModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString();
    final title = json['title']?.toString() ?? json['name']?.toString() ?? 'Vazifa';
    final course = json['group_name']?.toString() ??
        json['course_name']?.toString() ??
        json['course']?.toString() ??
        'Back end 05';
    final description = json['description']?.toString() ?? 'Amaliy topshiriq va mashg\'ulotlar';
    final lessonId = (json['lesson'] ?? json['lesson_id'] ?? '').toString();
    final lessonTitle = json['lesson_title']?.toString();
    final attachmentUrl = json['attachment_url']?.toString() ??
        json['attachment']?.toString() ??
        json['file_url']?.toString() ??
        json['file']?.toString();

    // ── 1. Format ISO 8601 Deadline ──
    String deadlineStr = 'Muddatsiz';
    final rawDeadline = json['deadline']?.toString() ?? json['due_date']?.toString();
    if (rawDeadline != null && rawDeadline.isNotEmpty && rawDeadline != 'null') {
      try {
        final dt = DateTime.parse(rawDeadline).toLocal();
        final now = DateTime.now();
        const months = [
          'yanvar', 'fevral', 'mart', 'aprel', 'may', 'iyun',
          'iyul', 'avgust', 'sentabr', 'oktabr', 'noyabr', 'dekabr'
        ];
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');

        final diffDays = DateTime(dt.year, dt.month, dt.day)
            .difference(DateTime(now.year, now.month, now.day))
            .inDays;

        if (diffDays == 0) {
          deadlineStr = 'Bugun, $hour:$minute';
        } else if (diffDays == 1) {
          deadlineStr = 'Ertaga, $hour:$minute';
        } else if (diffDays == -1) {
          deadlineStr = 'Kecha, $hour:$minute';
        } else {
          deadlineStr = '${dt.day}-${months[dt.month - 1]}, $hour:$minute';
        }
      } catch (_) {
        deadlineStr = rawDeadline;
      }
    }

    // ── 2. Parse My Submission (score, status, mentor feedback) ──
    int? score;
    String? mentorFeedback;
    String? githubUrl;
    HomeworkStatusModel statusModel = HomeworkStatusModel.pending;

    final mySub = json['my_submission'];
    if (mySub is Map<String, dynamic>) {
      score = (mySub['score'] as num?)?.toInt();
      mentorFeedback = mySub['mentor_feedback']?.toString() ??
          mySub['feedback']?.toString() ??
          mySub['comment']?.toString();
      githubUrl = mySub['github_url']?.toString() ??
          mySub['link']?.toString() ??
          mySub['url']?.toString();

      final subStatus = mySub['status']?.toString().toLowerCase() ?? '';
      if (subStatus == 'graded' || subStatus == 'reviewed' || score != null) {
        statusModel = HomeworkStatusModel.reviewed;
      } else if (subStatus == 'submitted' || subStatus == 'topshirildi') {
        statusModel = HomeworkStatusModel.submitted;
      } else {
        statusModel = HomeworkStatusModel.pending;
      }
    } else {
      score = (json['score'] as num?)?.toInt() ?? (json['grade'] as num?)?.toInt();
      mentorFeedback = json['mentor_feedback']?.toString() ?? json['feedback']?.toString();
      githubUrl = json['github_url']?.toString() ?? json['link']?.toString();

      final statusStr = json['status']?.toString().toLowerCase() ?? '';
      if (statusStr == 'graded' || statusStr == 'reviewed' || score != null || json['is_reviewed'] == true) {
        statusModel = HomeworkStatusModel.reviewed;
      } else if (statusStr == 'submitted' || json['is_submitted'] == true) {
        statusModel = HomeworkStatusModel.submitted;
      } else {
        statusModel = HomeworkStatusModel.pending;
      }
    }

    return HomeworkItemModel(
      id: id,
      title: title,
      course: course,
      deadline: deadlineStr,
      description: description,
      status: statusModel,
      githubRepoUrl: githubUrl,
      score: score,
      mentorFeedback: mentorFeedback,
      lessonId: lessonId.isNotEmpty ? lessonId : null,
      lessonTitle: lessonTitle,
      attachmentUrl: attachmentUrl,
    );
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
        lessonId: lessonId,
        lessonTitle: lessonTitle,
        attachmentUrl: attachmentUrl,
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
        lessonId: entity.lessonId,
        lessonTitle: entity.lessonTitle,
        attachmentUrl: entity.attachmentUrl,
      );
}
