import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/homework/domain/entities/homework.dart';
import 'package:m_it_student_platform/features/homework/domain/repositories/homework_repository.dart';

class GetHomeworkUseCase {
  final HomeworkRepository _repository;

  const GetHomeworkUseCase({required HomeworkRepository repository})
      : _repository = repository;

  Future<Result<List<HomeworkItem>>> call() => _repository.getHomeworkList();
}
