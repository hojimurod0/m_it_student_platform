import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/notifications/domain/repositories/notifications_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationsRepository _repository;

  const MarkNotificationReadUseCase({required NotificationsRepository repository})
      : _repository = repository;

  Future<Result<void>> call(String id) => _repository.markAsRead(id);
}
