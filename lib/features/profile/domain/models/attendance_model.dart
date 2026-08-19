class AttendanceRecord {
  const AttendanceRecord({
    required this.subject,
    required this.attended,
    required this.total,
    required this.percentage,
  });

  final String subject;
  final int attended;
  final int total;
  final int percentage;
}
