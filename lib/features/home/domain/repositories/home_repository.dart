import 'package:m_it_student_platform/features/home/domain/models/announcement_model.dart';
import 'package:m_it_student_platform/features/lessons/domain/models/lesson_model.dart';

abstract class HomeRepository {
  Future<Lesson> getFeaturedClass();
  Future<List<Announcement>> getAnnouncements();
  Future<Announcement> getAnnouncementDetails(String id);
}
