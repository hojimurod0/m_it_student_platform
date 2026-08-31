import 'package:m_it_student_platform/features/lessons/domain/models/lesson_model.dart';

abstract class LessonsRepository {
  Future<List<StudentGroup>> getStudentGroups();
  Future<List<Lesson>> getTodayLessons();
  Future<List<Lesson>> getTomorrowLessons();
  Future<List<Lesson>> getCompletedLessons();
  Future<Lesson> getLessonDetails(String lessonId);
  Future<List<TopicModel>> getLessonTopics();
}
