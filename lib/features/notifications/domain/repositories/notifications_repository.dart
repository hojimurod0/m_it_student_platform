import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/notifications/domain/entities/notification.dart';

abstract class NotificationsRepository {
  Future<Result<List<InAppNotification>>> getNotifications();
  Future<Result<void>> markAsRead(String id);
}
