import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/leaderboard/domain/entities/leaderboard_entry.dart';

abstract class LeaderboardRepository {
  Future<Result<List<LeaderboardEntry>>> getLeaderboard({String? groupId});
}
