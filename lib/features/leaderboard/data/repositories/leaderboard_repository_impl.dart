import 'package:m_it_student_platform/core/error/exceptions.dart';
import 'package:m_it_student_platform/core/error/failures.dart';
import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/leaderboard/data/datasources/leaderboard_remote_data_source.dart';
import 'package:m_it_student_platform/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:m_it_student_platform/features/leaderboard/domain/repositories/leaderboard_repository.dart';

export 'package:m_it_student_platform/features/leaderboard/domain/repositories/leaderboard_repository.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource _dataSource;

  LeaderboardRepositoryImpl({required LeaderboardRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<List<LeaderboardEntry>>> getLeaderboard({String? groupId}) async {
    try {
      final models = await _dataSource.getLeaderboard(groupId: groupId);
      return Success(models.map((m) => m.toEntity()).toList());
    } on NetworkException catch (e) {
      return FailureResult(NetworkFailure(e.message, e.cause));
    } on UnauthorizedException catch (e) {
      return FailureResult(UnauthorizedFailure(e.message, e.cause));
    } on ForbiddenException catch (e) {
      return FailureResult(ForbiddenFailure(e.message, e.cause));
    } on NotFoundException catch (e) {
      return FailureResult(NotFoundFailure(e.message, e.cause));
    } on ParseException catch (e) {
      return FailureResult(ParseFailure(e.message, e.cause));
    } on ServerException catch (e) {
      return FailureResult(ServerFailure(e.message, e.cause));
    } catch (e) {
      return FailureResult(UnknownFailure('Reytingni olishda kutilmagan xatolik', e));
    }
  }
}
