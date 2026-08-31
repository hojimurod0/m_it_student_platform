import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/groups/domain/entities/group.dart';

abstract class GroupsRepository {
  Future<Result<List<Group>>> getMyGroups();
}
