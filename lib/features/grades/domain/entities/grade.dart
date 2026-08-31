/// Pure Domain Entity: Baho (Grade) ob'ekti
class GradeItem {
  final String id;
  final String lessonTitle;
  final int score;
  final int maxScore;
  final String date;
  final int coins;
  final String? mentorComment;
  final String? groupName;

  const GradeItem({
    required this.id,
    required this.lessonTitle,
    required this.score,
    required this.maxScore,
    required this.date,
    this.coins = 0,
    this.mentorComment,
    this.groupName,
  });

  double get percentage => maxScore > 0 ? (score / maxScore) * 100 : 0;

  String get gradeLabel {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  GradeItem copyWith({
    String? id,
    String? lessonTitle,
    int? score,
    int? maxScore,
    String? date,
    int? coins,
    String? mentorComment,
    String? groupName,
  }) {
    return GradeItem(
      id: id ?? this.id,
      lessonTitle: lessonTitle ?? this.lessonTitle,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      date: date ?? this.date,
      coins: coins ?? this.coins,
      mentorComment: mentorComment ?? this.mentorComment,
      groupName: groupName ?? this.groupName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
