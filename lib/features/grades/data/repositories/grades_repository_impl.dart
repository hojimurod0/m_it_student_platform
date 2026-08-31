import 'package:m_it_student_platform/core/error/exceptions.dart';
import 'package:m_it_student_platform/core/error/failures.dart';
import 'package:m_it_student_platform/core/storage/app_cache_service.dart';
import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/grades/data/datasources/grades_remote_data_source.dart';
import 'package:m_it_student_platform/features/grades/data/models/grade_model.dart';
import 'package:m_it_student_platform/features/grades/domain/entities/grade.dart';
import 'package:m_it_student_platform/features/grades/domain/repositories/grades_repository.dart';

export 'package:m_it_student_platform/features/grades/domain/repositories/grades_repository.dart';

class GradesRepositoryImpl implements GradesRepository {
  final GradesRemoteDataSource _dataSource;

  GradesRepositoryImpl({required GradesRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<List<GradeItem>>> getMyGrades() async {
    try {
      final models = await _dataSource.getMyGrades();
      final items = models.map((m) => m.toEntity()).toList();
      if (items.isNotEmpty) {
        await AppCacheService.setCache(
          AppCacheService.keyGrades,
          models.map((m) => m.toJson()).toList(),
          ttl: const Duration(hours: 4),
        );
      }
      return Success(items);
    } on NetworkException catch (e) {
      final cached = AppCacheService.getCache(AppCacheService.keyGrades);
      if (cached is List && cached.isNotEmpty) {
        final items = cached
            .whereType<Map>()
            .map((item) => GradeItemModel.fromJson(Map<String, dynamic>.from(item)).toEntity())
            .toList();
        return Success(items);
      }
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
      final cached = AppCacheService.getCache(AppCacheService.keyGrades);
      if (cached is List && cached.isNotEmpty) {
        final items = cached
            .whereType<Map>()
            .map((item) => GradeItemModel.fromJson(Map<String, dynamic>.from(item)).toEntity())
            .toList();
        return Success(items);
      }
      return FailureResult(ServerFailure(e.message, e.cause));
    } catch (e) {
      final cached = AppCacheService.getCache(AppCacheService.keyGrades);
      if (cached is List && cached.isNotEmpty) {
        final items = cached
            .whereType<Map>()
            .map((item) => GradeItemModel.fromJson(Map<String, dynamic>.from(item)).toEntity())
            .toList();
        return Success(items);
      }
      return FailureResult(UnknownFailure('Baholarni olishda kutilmagan xatolik', e));
    }
  }
}
