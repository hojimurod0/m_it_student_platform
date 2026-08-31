import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';

abstract class HomeRemoteDataSource {
  Future<dynamic> fetchFeaturedClass();
  Future<dynamic> fetchGroups();
  Future<dynamic> fetchAnnouncements();
  Future<dynamic> fetchAnnouncementDetails(String id);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<dynamic> fetchFeaturedClass() async {
    return await _apiClient.get(AppConfig.portalStudentSchedule);
  }

  @override
  Future<dynamic> fetchGroups() async {
    return await _apiClient.get(AppConfig.portalStudentGroups);
  }

  @override
  Future<dynamic> fetchAnnouncements() async {
    return await _apiClient.get(AppConfig.lmsAnnouncements);
  }

  @override
  Future<dynamic> fetchAnnouncementDetails(String id) async {
    return await _apiClient.get('${AppConfig.lmsAnnouncements}$id/');
  }
}
