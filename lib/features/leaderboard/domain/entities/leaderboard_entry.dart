/// Pure Domain Entity: Reyting (Leaderboard) yozuvi
class LeaderboardEntry {
  final int rank;
  final String studentName;
  final int totalCoins;
  final int attendancePercentage;
  final double averageScore;
  final bool isCurrentUser;
  final String? studentPhoto;
  final String? studentId;

  const LeaderboardEntry({
    required this.rank,
    required this.studentName,
    required this.totalCoins,
    required this.attendancePercentage,
    required this.averageScore,
    this.isCurrentUser = false,
    this.studentPhoto,
    this.studentId,
  });

  bool get isMe => isCurrentUser;
  int get coins => totalCoins;

  LeaderboardEntry copyWith({
    int? rank,
    String? studentName,
    int? totalCoins,
    int? attendancePercentage,
    double? averageScore,
    bool? isCurrentUser,
    String? studentPhoto,
    String? studentId,
  }) {
    return LeaderboardEntry(
      rank: rank ?? this.rank,
      studentName: studentName ?? this.studentName,
      totalCoins: totalCoins ?? this.totalCoins,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      averageScore: averageScore ?? this.averageScore,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      studentPhoto: studentPhoto ?? this.studentPhoto,
      studentId: studentId ?? this.studentId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderboardEntry &&
          runtimeType == other.runtimeType &&
          rank == other.rank &&
          studentName == other.studentName;

  @override
  int get hashCode => rank.hashCode ^ studentName.hashCode;
}
