import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/grades/domain/entities/grade.dart';
import 'package:m_it_student_platform/features/grades/domain/repositories/grades_repository.dart';

class GetMyGradesUseCase {
  final GradesRepository _repository;

  const GetMyGradesUseCase({required GradesRepository repository})
      : _repository = repository;

  Future<Result<List<GradeItem>>> call() => _repository.getMyGrades();
}
