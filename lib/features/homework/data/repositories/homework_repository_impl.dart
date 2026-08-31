import 'package:m_it_student_platform/core/error/exceptions.dart';
import 'package:m_it_student_platform/core/error/failures.dart';
import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/homework/data/datasources/homework_remote_data_source.dart';
import 'package:m_it_student_platform/features/homework/domain/entities/homework.dart';
import 'package:m_it_student_platform/features/homework/domain/repositories/homework_repository.dart';

export 'package:m_it_student_platform/features/homework/domain/repositories/homework_repository.dart';

class HomeworkRepositoryImpl implements HomeworkRepository {
  final HomeworkRemoteDataSource _dataSource;

  HomeworkRepositoryImpl({required HomeworkRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<List<HomeworkItem>>> getHomeworkList() async {
    try {
      final models = await _dataSource.getHomeworkList();
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
      return FailureResult(UnknownFailure('Vazifalarni olishda kutilmagan xatolik', e));
    }
  }

  @override
  Future<Result<HomeworkItem>> submitHomework(
    String homeworkId,
    String githubUrl, {
    String? text,
    String? comment,
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    try {
      final model = await _dataSource.submitHomework(
        homeworkId: homeworkId,
        text: text,
        githubUrl: githubUrl,
        comment: comment,
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      return Success(model.toEntity());
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
      return FailureResult(UnknownFailure('Vazifani topshirishda kutilmagan xatolik', e));
    }
  }
}
