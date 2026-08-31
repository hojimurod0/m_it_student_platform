import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/features/announcements/data/models/announcement_model.dart';

abstract class AnnouncementsRemoteDataSource {
  Future<List<AnnouncementModel>> getAnnouncements();
}

class AnnouncementsRemoteDataSourceImpl implements AnnouncementsRemoteDataSource {
  final ApiClient _apiClient;

  AnnouncementsRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<AnnouncementModel>> getAnnouncements() async {
    try {
      final response = await _apiClient.get(AppConfig.lmsAnnouncements);

      List<dynamic> rawList = [];
      if (response is List) {
        rawList = response;
      } else if (response is Map && response['results'] is List) {
        rawList = response['results'] as List;
      } else if (response is Map && response['announcements'] is List) {
        rawList = response['announcements'] as List;
      } else if (response is Map && response['data'] is List) {
        rawList = response['data'] as List;
      } else {
        throw const ParseException('Kutilmagan e\'lonlar formati');
      }

      return rawList
          .whereType<Map>()
          .map((item) => AnnouncementModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode == 401) throw UnauthorizedException(e.message, e);
      if (e.statusCode == 403) throw ForbiddenException(e.message, e);
      if (e.statusCode == 404) throw NotFoundException(e.message, e);
      throw ServerException(e.message, e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('E\'lonlarni yuklashda aloqa xatosi', e);
    }
  }
}
