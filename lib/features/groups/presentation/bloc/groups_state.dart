import 'package:m_it_student_platform/core/error/failures.dart';
import 'package:m_it_student_platform/features/groups/domain/entities/group.dart';

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
  final List<Group> groups;

  const GroupsLoaded(this.groups);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GroupsLoaded && groups == other.groups;

  @override
  int get hashCode => groups.hashCode;
}

class GroupsError extends GroupsState {
  final Failure failure;
  final String message;

  GroupsError(this.failure) : message = failure.message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GroupsError && failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}
