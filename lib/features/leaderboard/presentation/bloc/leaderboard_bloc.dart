import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/core/error/failures.dart';
import 'package:m_it_student_platform/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:m_it_student_platform/features/leaderboard/domain/usecases/get_leaderboard_usecase.dart';

export 'package:m_it_student_platform/features/leaderboard/domain/entities/leaderboard_entry.dart';

// ── Events ─────────────────────────────────────────────────────────────────

sealed class LeaderboardEvent {
  const LeaderboardEvent();
}

class LoadLeaderboardEvent extends LeaderboardEvent {
  const LoadLeaderboardEvent({required this.groupId, this.myStudentId});
  final String groupId;
  final String? myStudentId;
}

// ── States ─────────────────────────────────────────────────────────────────

sealed class LeaderboardState {
  const LeaderboardState();
}

class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();
}

class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading();
}

class LeaderboardLoaded extends LeaderboardState {
  const LeaderboardLoaded(this.entries, {this.groupId = ''});
  final List<LeaderboardEntry> entries;
  final String groupId;

  LeaderboardEntry? get myEntry => entries.where((e) => e.isMe).firstOrNull;
  List<LeaderboardEntry> get top3 => entries.take(3).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderboardLoaded && runtimeType == other.runtimeType && entries == other.entries;

  @override
  int get hashCode => entries.hashCode;
}

class LeaderboardError extends LeaderboardState {
  const LeaderboardError({required this.failure, required this.message});
  final Failure failure;
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderboardError && runtimeType == other.runtimeType && failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}

// ── BLoC ────────────────────────────────────────────────────────────────────

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc({required GetLeaderboardUseCase getLeaderboardUseCase})
      : _getLeaderboardUseCase = getLeaderboardUseCase,
        super(const LeaderboardInitial()) {
    on<LoadLeaderboardEvent>(_onLoad);
  }

  final GetLeaderboardUseCase _getLeaderboardUseCase;

  Future<void> _onLoad(LoadLeaderboardEvent event, Emitter<LeaderboardState> emit) async {
    emit(const LeaderboardLoading());
    final result = await _getLeaderboardUseCase(groupId: event.groupId);
    result.when(
      success: (entries) => emit(LeaderboardLoaded(entries, groupId: event.groupId)),
      failure: (failure) => emit(LeaderboardError(failure: failure, message: failure.message)),
    );
  }
}
