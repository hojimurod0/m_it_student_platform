import 'package:m_it_student_platform/core/error/exceptions.dart';
import 'package:m_it_student_platform/core/error/failures.dart';
import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/groups/data/datasources/groups_remote_data_source.dart';
import 'package:m_it_student_platform/features/groups/domain/entities/group.dart';
import 'package:m_it_student_platform/features/groups/domain/repositories/groups_repository.dart';

export 'package:m_it_student_platform/features/groups/domain/repositories/groups_repository.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  final GroupsRemoteDataSource _dataSource;

  GroupsRepositoryImpl({required GroupsRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<List<Group>>> getMyGroups() async {
    try {
      final models = await _dataSource.getMyGroups();
      final entities = models.map((m) => m.toEntity()).toList();
      return Success(entities);
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
      return FailureResult(UnknownFailure('Guruhlarni olishda kutilmagan xatolik', e));
    }
  }
}
