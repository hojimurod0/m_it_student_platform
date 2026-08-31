import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/announcements/domain/entities/announcement.dart';

abstract class AnnouncementsRepository {
  Future<Result<List<Announcement>>> getAnnouncements();
}
