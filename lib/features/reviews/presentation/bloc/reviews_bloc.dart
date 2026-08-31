import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/features/reviews/data/repositories/reviews_repository_impl.dart';

// ── Events ─────────────────────────────────────────────────────────────────

abstract class ReviewsEvent {
  const ReviewsEvent();
}

class SubmitReviewEvent extends ReviewsEvent {
  const SubmitReviewEvent({
    required this.rating,
    this.comment,
    this.mentorId,
  });
  final int rating;
  final String? comment;
  final String? mentorId;
}

class ResetReviewEvent extends ReviewsEvent {
  const ResetReviewEvent();
}

// ── States ─────────────────────────────────────────────────────────────────

abstract class ReviewsState {
  const ReviewsState();
}

class ReviewsInitial extends ReviewsState {
  const ReviewsInitial();
}

class ReviewsSubmitting extends ReviewsState {
  const ReviewsSubmitting();
}

class ReviewsSuccess extends ReviewsState {
  const ReviewsSuccess();
}

class ReviewsError extends ReviewsState {
  const ReviewsError(this.message);
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewsError && runtimeType == other.runtimeType && message == other.message;

  @override
  int get hashCode => message.hashCode;
}

// ── BLoC ────────────────────────────────────────────────────────────────────

class ReviewsBloc extends Bloc<ReviewsEvent, ReviewsState> {
  ReviewsBloc({ReviewsRepository? repository})
      : _repository = repository ?? ReviewsRepositoryImpl(),
        super(const ReviewsInitial()) {
    on<SubmitReviewEvent>(_onSubmit);
    on<ResetReviewEvent>(_onReset);
  }

  final ReviewsRepository _repository;

  Future<void> _onSubmit(SubmitReviewEvent event, Emitter<ReviewsState> emit) async {
    emit(const ReviewsSubmitting());
    try {
      await _repository.submitReview(
        rating: event.rating,
        comment: event.comment,
        mentorId: event.mentorId,
      );
      emit(const ReviewsSuccess());
    } catch (e) {
      emit(ReviewsError(e.toString()));
    }
  }

  void _onReset(ResetReviewEvent event, Emitter<ReviewsState> emit) {
    emit(const ReviewsInitial());
  }
}
