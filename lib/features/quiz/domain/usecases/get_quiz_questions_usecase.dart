import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/quiz/domain/entities/quiz.dart';
import 'package:m_it_student_platform/features/quiz/domain/repositories/quiz_repository.dart';

class GetQuizQuestionsUseCase {
  final QuizRepository _repository;

  const GetQuizQuestionsUseCase({required QuizRepository repository})
      : _repository = repository;

  Future<Result<List<QuizQuestion>>> call() =>
      _repository.getQuizQuestions();
}
