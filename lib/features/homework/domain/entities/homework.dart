enum HomeworkStatus {
  pending,
  submitted,
  reviewed,
}

/// Pure Domain Entity: Uyga vazifa (Homework) ob'ekti
class HomeworkItem {
  final String id;
  final String title;
  final String course;
  final String deadline;
  final String description;
  final HomeworkStatus status;
  final String? githubRepoUrl;
  final int? score;
  final String? mentorFeedback;

  const HomeworkItem({
    required this.id,
    required this.title,
    required this.course,
    required this.deadline,
    required this.description,
    required this.status,
    this.githubRepoUrl,
    this.score,
    this.mentorFeedback,
  });

  HomeworkItem copyWith({
    String? id,
    String? title,
    String? course,
    String? deadline,
    String? description,
    HomeworkStatus? status,
    String? githubRepoUrl,
    int? score,
    String? mentorFeedback,
  }) {
    return HomeworkItem(
      id: id ?? this.id,
      title: title ?? this.title,
      course: course ?? this.course,
      deadline: deadline ?? this.deadline,
      description: description ?? this.description,
      status: status ?? this.status,
      githubRepoUrl: githubRepoUrl ?? this.githubRepoUrl,
      score: score ?? this.score,
      mentorFeedback: mentorFeedback ?? this.mentorFeedback,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeworkItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
