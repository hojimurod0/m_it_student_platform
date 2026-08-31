import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/features/leaderboard/data/models/leaderboard_model.dart';

abstract class LeaderboardRemoteDataSource {
  Future<List<LeaderboardEntryModel>> getLeaderboard({String? groupId});
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final ApiClient _apiClient;

  LeaderboardRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<LeaderboardEntryModel>> getLeaderboard({String? groupId}) async {
    try {
      final endpoint = groupId != null
          ? AppConfig.lmsLeaderboard(groupId)
          : AppConfig.portalLeaderboard;
      final response = await _apiClient.get(endpoint);

      List<dynamic> rawList = [];
      if (response is List) {
        rawList = response;
      } else if (response is Map && response['results'] is List) {
        rawList = response['results'] as List;
      } else if (response is Map && response['leaderboard'] is List) {
        rawList = response['leaderboard'] as List;
      } else if (response is Map && response['data'] is List) {
        rawList = response['data'] as List;
      } else {
        throw const ParseException('Kutilmagan reyting ma\'lumotlar formati');
      }

      return rawList
          .whereType<Map>()
          .map((item) => LeaderboardEntryModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode == 401) throw UnauthorizedException(e.message, e);
      if (e.statusCode == 403) throw ForbiddenException(e.message, e);
      if (e.statusCode == 404) throw NotFoundException(e.message, e);
      throw ServerException(e.message, e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Reytingni yuklashda aloqa xatosi', e);
    }
  }
}
