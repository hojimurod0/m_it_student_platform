import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/quiz/domain/entities/quiz.dart';

abstract class QuizRepository {
  Future<Result<List<QuizQuestion>>> getQuizQuestions();
}
