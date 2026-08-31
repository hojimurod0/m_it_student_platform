import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:m_it_student_platform/features/leaderboard/domain/repositories/leaderboard_repository.dart';

class GetLeaderboardUseCase {
  final LeaderboardRepository _repository;

  const GetLeaderboardUseCase({required LeaderboardRepository repository})
      : _repository = repository;

  Future<Result<List<LeaderboardEntry>>> call({String? groupId}) =>
      _repository.getLeaderboard(groupId: groupId);
}
