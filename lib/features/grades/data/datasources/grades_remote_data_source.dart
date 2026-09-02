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
      }

      List<GradeItemModel> grades = rawList
          .whereType<Map>()
          .map((item) => GradeItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      // Extract real evaluated homeworks from /portal/student/my-homeworks/
      try {
        final hwResponse = await _apiClient.get(AppConfig.portalStudentHomeworks);
        List<dynamic> hwList = [];
        if (hwResponse is List) {
          hwList = hwResponse;
        } else if (hwResponse is Map && hwResponse['homeworks'] is List) {
          hwList = hwResponse['homeworks'] as List;
        } else if (hwResponse is Map && hwResponse['results'] is List) {
          hwList = hwResponse['results'] as List;
        }

        for (final hw in hwList) {
          if (hw is Map) {
            final mySub = hw['my_submission'];
            final s = (mySub is Map ? (mySub['score'] as num?)?.toInt() : null) ??
                (hw['score'] as num?)?.toInt();
            if (s != null && s > 0) {
              final title = hw['lesson_title']?.toString() ??
                  hw['title']?.toString() ??
                  'Uyga vazifa';
              final alreadyAdded = grades.any((g) => g.id == hw['id'].toString() || g.lessonTitle == title);
              if (!alreadyAdded) {
                grades.add(
                  GradeItemModel(
                    id: (hw['id'] ?? '').toString(),
                    lessonTitle: title,
                    score: s,
                    maxScore: (hw['max_score'] as num?)?.toInt() ?? 100,
                    date: (mySub is Map ? mySub['submitted_at']?.toString() : null) ??
                        hw['created_at']?.toString() ??
                        '',
                    coins: (s / 10).round(),
                    mentorComment: mySub is Map ? mySub['comment']?.toString() : null,
                    groupName: hw['group_name']?.toString(),
                  ),
                );
              }
            }
          }
        }
      } catch (_) {}

      return grades;
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
