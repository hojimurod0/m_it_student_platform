import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/features/attendance/data/models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<List<AttendanceRecordModel>> getMyAttendance();
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final ApiClient _apiClient;

  AttendanceRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<AttendanceRecordModel>> getMyAttendance() async {
    try {
      final response = await _apiClient.get(AppConfig.portalStudentAttendance);

      List<dynamic> rawList = [];
      if (response is List) {
        rawList = response;
      } else if (response is Map) {
        if (response['days'] is List) {
          rawList = response['days'] as List;
        } else if (response['results'] is List) {
          rawList = response['results'] as List;
        } else if (response['attendance'] is List) {
          rawList = response['attendance'] as List;
        } else if (response['records'] is List) {
          rawList = response['records'] as List;
        } else if (response['data'] is List) {
          rawList = response['data'] as List;
        } else {
          // If response is a single object or summary, wrap it or return empty
          rawList = [];
        }
      }

      return rawList
          .whereType<Map>()
          .map((item) => AttendanceRecordModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode == 401) throw UnauthorizedException(e.message, e);
      if (e.statusCode == 403) throw ForbiddenException(e.message, e);
      if (e.statusCode == 404) throw NotFoundException(e.message, e);
      throw ServerException(e.message, e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Davomatni yuklashda aloqa xatosi', e);
    }
  }
}
