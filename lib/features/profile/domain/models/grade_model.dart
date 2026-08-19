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
}
