import 'package:json_annotation/json_annotation.dart';
import 'package:m_it_student_platform/features/leaderboard/domain/entities/leaderboard_entry.dart';

part 'leaderboard_model.g.dart';

@JsonSerializable()
class LeaderboardEntryModel {
  const LeaderboardEntryModel({
    required this.rank,
    required this.studentName,
    this.totalCoins = 0,
    this.attendancePercentage = 100,
    this.averageScore = 0.0,
    this.isCurrentUser = false,
    this.studentPhoto,
    this.studentId,
  });

  final int rank;
  @JsonKey(name: 'student_name', defaultValue: 'O\'quvchi')
  final String studentName;
  @JsonKey(name: 'coins', defaultValue: 0)
  final int totalCoins;
  @JsonKey(name: 'attendance_percent', defaultValue: 100)
  final int attendancePercentage;
  @JsonKey(name: 'average_score', defaultValue: 0.0)
  final double averageScore;
  @JsonKey(name: 'is_me', defaultValue: false)
  final bool isCurrentUser;
  @JsonKey(name: 'photo')
  final String? studentPhoto;
  @JsonKey(name: 'student_id')
  final String? studentId;

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeaderboardEntryModelToJson(this);

  LeaderboardEntry toEntity() => LeaderboardEntry(
        rank: rank,
        studentName: studentName,
        totalCoins: totalCoins,
        attendancePercentage: attendancePercentage,
        averageScore: averageScore,
        isCurrentUser: isCurrentUser,
        studentPhoto: studentPhoto,
        studentId: studentId,
      );

  factory LeaderboardEntryModel.fromEntity(LeaderboardEntry entity) =>
      LeaderboardEntryModel(
        rank: entity.rank,
        studentName: entity.studentName,
        totalCoins: entity.totalCoins,
        attendancePercentage: entity.attendancePercentage,
        averageScore: entity.averageScore,
        isCurrentUser: entity.isCurrentUser,
        studentPhoto: entity.studentPhoto,
        studentId: entity.studentId,
      );
}
