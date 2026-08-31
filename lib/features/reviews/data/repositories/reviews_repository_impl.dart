import 'package:m_it_student_platform/features/reviews/data/datasources/reviews_remote_data_source.dart';

abstract class ReviewsRepository {
  Future<void> submitReview({
    required int rating,
    String? comment,
    String? mentorId,
  });
}

class ReviewsRepositoryImpl implements ReviewsRepository {
  ReviewsRepositoryImpl({ReviewsRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? ReviewsRemoteDataSourceImpl();

  final ReviewsRemoteDataSource _dataSource;

  @override
  Future<void> submitReview({
    required int rating,
    String? comment,
    String? mentorId,
  }) =>
      _dataSource.submitReview(rating: rating, comment: comment, mentorId: mentorId);
}
