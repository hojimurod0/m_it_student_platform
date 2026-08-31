// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardEntryModel _$LeaderboardEntryModelFromJson(
  Map<String, dynamic> json,
) => LeaderboardEntryModel(
  rank: (json['rank'] as num).toInt(),
  studentName: json['student_name'] as String? ?? "O'quvchi",
  totalCoins: (json['coins'] as num?)?.toInt() ?? 0,
  attendancePercentage: (json['attendance_percent'] as num?)?.toInt() ?? 100,
  averageScore: (json['average_score'] as num?)?.toDouble() ?? 0.0,
  isCurrentUser: json['is_me'] as bool? ?? false,
  studentPhoto: json['photo'] as String?,
  studentId: json['student_id'] as String?,
);

Map<String, dynamic> _$LeaderboardEntryModelToJson(
  LeaderboardEntryModel instance,
) => <String, dynamic>{
  'rank': instance.rank,
  'student_name': instance.studentName,
  'coins': instance.totalCoins,
  'attendance_percent': instance.attendancePercentage,
  'average_score': instance.averageScore,
  'is_me': instance.isCurrentUser,
  'photo': instance.studentPhoto,
  'student_id': instance.studentId,
};
