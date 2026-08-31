import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/groups/domain/entities/group.dart';
import 'package:m_it_student_platform/features/groups/domain/repositories/groups_repository.dart';

/// O'quvchining guruhlarini olish UseCase'i
class GetMyGroupsUseCase {
  final GroupsRepository _repository;

  const GetMyGroupsUseCase({required GroupsRepository repository})
      : _repository = repository;

  Future<Result<List<Group>>> call() => _repository.getMyGroups();
}
