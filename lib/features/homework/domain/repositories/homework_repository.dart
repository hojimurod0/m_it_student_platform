import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/homework/domain/entities/homework.dart';

abstract class HomeworkRepository {
  Future<Result<List<HomeworkItem>>> getHomeworkList();
  Future<Result<HomeworkItem>> submitHomework(
    String homeworkId,
    String githubUrl, {
    String? text,
    String? comment,
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
  });
}
