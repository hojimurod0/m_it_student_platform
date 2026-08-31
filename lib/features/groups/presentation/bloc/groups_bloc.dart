import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/core/error/failures.dart';
import 'package:m_it_student_platform/features/groups/domain/entities/group.dart';
import 'package:m_it_student_platform/features/groups/domain/usecases/get_my_groups_usecase.dart';

export 'package:m_it_student_platform/features/groups/domain/entities/group.dart';

// ── Events ─────────────────────────────────────────────────────────────────

sealed class GroupsEvent {
  const GroupsEvent();
}

class LoadGroupsEvent extends GroupsEvent {
  const LoadGroupsEvent();
}

// ── States ─────────────────────────────────────────────────────────────────

sealed class GroupsState {
  const GroupsState();
}

class GroupsInitial extends GroupsState {
  const GroupsInitial();
}

class GroupsLoading extends GroupsState {
  const GroupsLoading();
}

class GroupsLoaded extends GroupsState {
  const GroupsLoaded(this.groups);
  final List<Group> groups;

  /// Returns the first active group's ID (used for leaderboard & chat)
  String? get primaryGroupId => groups.isNotEmpty ? groups.first.id : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupsLoaded && runtimeType == other.runtimeType && groups == other.groups;

  @override
  int get hashCode => groups.hashCode;
}

class GroupsError extends GroupsState {
  const GroupsError({required this.failure, required this.message});
  final Failure failure;
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupsError && runtimeType == other.runtimeType && failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}

// ── BLoC ────────────────────────────────────────────────────────────────────

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  GroupsBloc({required GetMyGroupsUseCase getMyGroupsUseCase})
      : _getMyGroupsUseCase = getMyGroupsUseCase,
        super(const GroupsInitial()) {
    on<LoadGroupsEvent>(_onLoad);
  }

  final GetMyGroupsUseCase _getMyGroupsUseCase;

  Future<void> _onLoad(LoadGroupsEvent event, Emitter<GroupsState> emit) async {
    emit(const GroupsLoading());
    final result = await _getMyGroupsUseCase();
    result.when(
      success: (groups) => emit(GroupsLoaded(groups)),
      failure: (failure) => emit(GroupsError(failure: failure, message: failure.message)),
    );
  }
}
