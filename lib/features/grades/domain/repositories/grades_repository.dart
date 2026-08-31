import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/grades/domain/entities/grade.dart';

abstract class GradesRepository {
  Future<Result<List<GradeItem>>> getMyGrades();
}
