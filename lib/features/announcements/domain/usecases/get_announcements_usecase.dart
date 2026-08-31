import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/announcements/domain/entities/announcement.dart';
import 'package:m_it_student_platform/features/announcements/domain/repositories/announcements_repository.dart';

class GetAnnouncementsUseCase {
  final AnnouncementsRepository _repository;

  const GetAnnouncementsUseCase({required AnnouncementsRepository repository})
      : _repository = repository;

  Future<Result<List<Announcement>>> call() =>
      _repository.getAnnouncements();
}
