import 'package:m_it_student_platform/core/error/exceptions.dart';
import 'package:m_it_student_platform/core/error/failures.dart';
import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/quiz/data/datasources/quiz_remote_data_source.dart';
import 'package:m_it_student_platform/features/quiz/domain/entities/quiz.dart';
import 'package:m_it_student_platform/features/quiz/domain/repositories/quiz_repository.dart';

export 'package:m_it_student_platform/features/quiz/domain/repositories/quiz_repository.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource _dataSource;

  QuizRepositoryImpl({required QuizRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<List<QuizQuestion>>> getQuizQuestions() async {
    try {
      final models = await _dataSource.getQuizQuestions();
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
      return FailureResult(UnknownFailure('Quiz savollarini olishda kutilmagan xatolik', e));
    }
  }
}
