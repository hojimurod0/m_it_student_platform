import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/notifications/domain/entities/notification.dart';
import 'package:m_it_student_platform/features/notifications/domain/repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository _repository;

  const GetNotificationsUseCase({required NotificationsRepository repository})
      : _repository = repository;

  Future<Result<List<InAppNotification>>> call() =>
      _repository.getNotifications();
}
