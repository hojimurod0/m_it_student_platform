import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/features/grades/data/models/grade_model.dart';

abstract class GradesRemoteDataSource {
  Future<List<GradeItemModel>> getMyGrades();
}

class GradesRemoteDataSourceImpl implements GradesRemoteDataSource {
  final ApiClient _apiClient;

  GradesRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<GradeItemModel>> getMyGrades() async {
    try {
      final response = await _apiClient.get(AppConfig.portalStudentGrades);

      List<dynamic> rawList = [];
      if (response is List) {
        rawList = response;
      } else if (response is Map && response['results'] is List) {
        rawList = response['results'] as List;
      } else if (response is Map && response['grades'] is List) {
        rawList = response['grades'] as List;
      } else if (response is Map && response['data'] is List) {
        rawList = response['data'] as List;
      } else {
        throw const ParseException('Kutilmagan baholar formati');
      }

      return rawList
          .whereType<Map>()
          .map((item) => GradeItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode == 401) throw UnauthorizedException(e.message, e);
      if (e.statusCode == 403) throw ForbiddenException(e.message, e);
      if (e.statusCode == 404) throw NotFoundException(e.message, e);
      throw ServerException(e.message, e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Baholarni yuklashda aloqa xatosi', e);
    }
  }
}
