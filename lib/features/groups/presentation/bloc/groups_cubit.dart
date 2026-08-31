import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/features/groups/domain/usecases/get_my_groups_usecase.dart';
import 'package:m_it_student_platform/features/groups/presentation/bloc/groups_state.dart';

export 'package:m_it_student_platform/features/groups/presentation/bloc/groups_state.dart';

class GroupsCubit extends Cubit<GroupsState> {
  final GetMyGroupsUseCase _getMyGroupsUseCase;

  GroupsCubit({required GetMyGroupsUseCase getMyGroupsUseCase})
      : _getMyGroupsUseCase = getMyGroupsUseCase,
        super(const GroupsInitial());

  Future<void> fetchGroups() async {
    emit(const GroupsLoading());

    final result = await _getMyGroupsUseCase();

    result.when(
      success: (groups) => emit(GroupsLoaded(groups)),
      failure: (failure) => emit(GroupsError(failure)),
    );
  }
}
