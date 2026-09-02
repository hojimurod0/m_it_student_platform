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
      final results = await Future.wait([
        _apiClient.get(AppConfig.portalStudentAttendance),
        _apiClient.get(AppConfig.portalStudentGroups).catchError((_) => null),
      ]);
      final response = results[0];
      final groupsResponse = results[1];

      String defaultStart = '11:00';
      String defaultEnd = '14:00';
      String? defaultGroupName;

      if (groupsResponse is List && groupsResponse.isNotEmpty && groupsResponse.first is Map) {
        final g = groupsResponse.first as Map;
        defaultStart = (g['lesson_start'] ?? defaultStart).toString();
        defaultEnd = (g['lesson_end'] ?? defaultEnd).toString();
        defaultGroupName = g['name']?.toString();
      } else if (groupsResponse is Map && groupsResponse['results'] is List && (groupsResponse['results'] as List).isNotEmpty) {
        final g = (groupsResponse['results'] as List).first;
        if (g is Map) {
          defaultStart = (g['lesson_start'] ?? defaultStart).toString();
          defaultEnd = (g['lesson_end'] ?? defaultEnd).toString();
          defaultGroupName = g['name']?.toString();
        }
      }

      List<dynamic> rawList = [];
      if (response is List) {
        rawList = response;
      } else if (response is Map) {
        if (response['days'] is List) {
          final allDays = response['days'] as List;
          final activeDays = allDays.where((d) {
            if (d is! Map) return false;
            final status = (d['status'] ?? '').toString().toLowerCase();
            final hasCheckin = d['checkin'] != null || d['check_in'] != null;
            final hasPresence = d['is_present'] != null || d['present'] != null;
            return (status.isNotEmpty && status != 'none') || hasCheckin || hasPresence;
          }).toList();
          rawList = activeDays;
        } else if (response['results'] is List) {
          rawList = response['results'] as List;
        } else if (response['attendance'] is List) {
          rawList = response['attendance'] as List;
        } else if (response['records'] is List) {
          rawList = response['records'] as List;
        } else if (response['data'] is List) {
          rawList = response['data'] as List;
        } else {
          rawList = [];
        }
      }

      return rawList
          .whereType<Map>()
          .map((item) {
            final m = Map<String, dynamic>.from(item);
            m['default_start'] = defaultStart;
            m['default_end'] = defaultEnd;
            m['default_group_name'] = defaultGroupName;
            return AttendanceRecordModel.fromJson(m);
          })
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
