import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/features/quiz/data/models/quiz_model.dart';

abstract class QuizRemoteDataSource {
  Future<List<QuizQuestionModel>> getQuizQuestions({String? quizId});
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final ApiClient _apiClient;

  QuizRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<QuizQuestionModel>> getQuizQuestions({String? quizId}) async {
    try {
      final endpoint = quizId != null
          ? AppConfig.lmsQuizDetail(quizId)
          : AppConfig.lmsQuizzes;
      final response = await _apiClient.get(endpoint);

      List<dynamic> rawList = [];
      if (response is List) {
        rawList = response;
      } else if (response is Map && response['results'] is List) {
        rawList = response['results'] as List;
      } else if (response is Map && response['questions'] is List) {
        rawList = response['questions'] as List;
      } else if (response is Map && response['data'] is List) {
        rawList = response['data'] as List;
      } else if (response is Map && response['data'] is Map && (response['data'] as Map)['questions'] is List) {
        rawList = (response['data'] as Map)['questions'] as List;
      } else {
        throw const ParseException('Kutilmagan quiz savollari formati');
      }

      return rawList
          .whereType<Map>()
          .map((item) {
            final map = Map<String, dynamic>.from(item);
            // Handle if options is a list of maps (e.g. [{'text': '...'}])
            if (map['options'] is List) {
              final rawOptions = map['options'] as List;
              if (rawOptions.isNotEmpty && rawOptions.first is Map) {
                map['options'] = rawOptions.map((opt) => opt['text']?.toString() ?? opt['title']?.toString() ?? '').toList();
                final correctIdx = rawOptions.indexWhere((opt) => opt['is_correct'] == true || opt['correct'] == true);
                if (correctIdx != -1) {
                  map['correct_index'] = correctIdx;
                }
              }
            }
            return QuizQuestionModel.fromJson(map);
          })
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode == 401) throw UnauthorizedException(e.message, e);
      if (e.statusCode == 403) throw ForbiddenException(e.message, e);
      if (e.statusCode == 404) throw NotFoundException(e.message, e);
      throw ServerException(e.message, e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Quiz savollarini yuklashda aloqa xatosi', e);
    }
  }
}
