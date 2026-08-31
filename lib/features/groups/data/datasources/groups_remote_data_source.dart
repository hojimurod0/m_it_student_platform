import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/features/groups/data/models/group_model.dart';

abstract class GroupsRemoteDataSource {
  Future<List<GroupModel>> getMyGroups();
}

class GroupsRemoteDataSourceImpl implements GroupsRemoteDataSource {
  final ApiClient _apiClient;

  GroupsRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<GroupModel>> getMyGroups() async {
    try {
      final response = await _apiClient.get(AppConfig.portalStudentGroups);

      List<dynamic> rawList = [];
      if (response is List) {
        rawList = response;
      } else if (response is Map && response['results'] is List) {
        rawList = response['results'] as List;
      } else if (response is Map && response['groups'] is List) {
        rawList = response['groups'] as List;
      } else if (response is Map && response['data'] is List) {
        rawList = response['data'] as List;
      } else {
        throw const ParseException('Kutilmagan guruhlar ma\'lumotlar formati');
      }

      return rawList
          .whereType<Map>()
          .map((item) => GroupModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        throw UnauthorizedException(e.message, e);
      } else if (e.statusCode == 403) {
        throw ForbiddenException(e.message, e);
      } else if (e.statusCode == 404) {
        throw NotFoundException(e.message, e);
      } else {
        throw ServerException(e.message, e);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Guruhlarni yuklashda aloqa xatosi', e);
    }
  }
}
