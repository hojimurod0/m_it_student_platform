import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/core/error/failures.dart';
import 'package:m_it_student_platform/features/announcements/domain/entities/announcement.dart';
import 'package:m_it_student_platform/features/announcements/domain/usecases/get_announcements_usecase.dart';

export 'package:m_it_student_platform/features/announcements/domain/entities/announcement.dart';

// ── Events ─────────────────────────────────────────────────────────────────

sealed class AnnouncementsEvent {
  const AnnouncementsEvent();
}

class LoadAnnouncementsEvent extends AnnouncementsEvent {
  const LoadAnnouncementsEvent();
}

// ── States ─────────────────────────────────────────────────────────────────

sealed class AnnouncementsState {
  const AnnouncementsState();
}

class AnnouncementsInitial extends AnnouncementsState {
  const AnnouncementsInitial();
}

class AnnouncementsLoading extends AnnouncementsState {
  const AnnouncementsLoading();
}

class AnnouncementsLoaded extends AnnouncementsState {
  const AnnouncementsLoaded(this.announcements);
  final List<Announcement> announcements;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnnouncementsLoaded && runtimeType == other.runtimeType && announcements == other.announcements;

  @override
  int get hashCode => announcements.hashCode;
}

class AnnouncementsError extends AnnouncementsState {
  const AnnouncementsError({required this.failure, required this.message});
  final Failure failure;
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnnouncementsError && runtimeType == other.runtimeType && failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}

// ── BLoC ────────────────────────────────────────────────────────────────────

class AnnouncementsBloc extends Bloc<AnnouncementsEvent, AnnouncementsState> {
  AnnouncementsBloc({required GetAnnouncementsUseCase getAnnouncementsUseCase})
      : _getAnnouncementsUseCase = getAnnouncementsUseCase,
        super(const AnnouncementsInitial()) {
    on<LoadAnnouncementsEvent>(_onLoad);
  }

  final GetAnnouncementsUseCase _getAnnouncementsUseCase;

  Future<void> _onLoad(LoadAnnouncementsEvent event, Emitter<AnnouncementsState> emit) async {
    emit(const AnnouncementsLoading());
    final result = await _getAnnouncementsUseCase();
    result.when(
      success: (announcements) => emit(AnnouncementsLoaded(announcements)),
      failure: (failure) => emit(AnnouncementsError(failure: failure, message: failure.message)),
    );
  }
}
