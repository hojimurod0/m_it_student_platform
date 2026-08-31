import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';

abstract class ReviewsRemoteDataSource {
  Future<void> submitReview({
    required int rating,
    String? comment,
    String? mentorId,
  });
}

class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  ReviewsRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<void> submitReview({
    required int rating,
    String? comment,
    String? mentorId,
  }) async {
    final body = <String, dynamic>{
      'rating': rating,
      'stars': rating,
    };
    if (comment != null && comment.isNotEmpty) {
      body['comment'] = comment;
      body['text'] = comment;
    }
    if (mentorId != null) {
      body['mentor'] = mentorId;
      body['mentor_id'] = mentorId;
    }
    await _apiClient.post(AppConfig.postReview, body: body);
  }
}
