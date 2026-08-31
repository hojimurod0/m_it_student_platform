import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/features/notifications/data/models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final ApiClient _apiClient;

  NotificationsRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.get(AppConfig.portalNotifications);

      List<dynamic> rawList = [];
      if (response is List) {
        rawList = response;
      } else if (response is Map && response['results'] is List) {
        rawList = response['results'] as List;
      } else if (response is Map && response['notifications'] is List) {
        rawList = response['notifications'] as List;
      } else if (response is Map && response['data'] is List) {
        rawList = response['data'] as List;
      } else {
        throw const ParseException('Kutilmagan bildirishnomalar formati');
      }

      return rawList
          .whereType<Map>()
          .map((item) => NotificationModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode == 401) throw UnauthorizedException(e.message, e);
      if (e.statusCode == 403) throw ForbiddenException(e.message, e);
      if (e.statusCode == 404) throw NotFoundException(e.message, e);
      throw ServerException(e.message, e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Bildirishnomalarni yuklashda aloqa xatosi', e);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.post('${AppConfig.portalNotifications}$id/read/');
    } on ApiException catch (e) {
      if (e.statusCode == 401) throw UnauthorizedException(e.message, e);
      if (e.statusCode == 403) throw ForbiddenException(e.message, e);
      if (e.statusCode == 404) throw NotFoundException(e.message, e);
      throw ServerException(e.message, e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Bildirishnomani o\'qildi deb belgilashda xatolik', e);
    }
  }
}
