import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/homework/domain/entities/homework.dart';
import 'package:m_it_student_platform/features/homework/domain/repositories/homework_repository.dart';

class SubmitHomeworkUseCase {
  final HomeworkRepository _repository;

  const SubmitHomeworkUseCase({required HomeworkRepository repository})
      : _repository = repository;

  Future<Result<HomeworkItem>> call({
    required String homeworkId,
    required String githubUrl,
  }) =>
      _repository.submitHomework(homeworkId, githubUrl);
}
