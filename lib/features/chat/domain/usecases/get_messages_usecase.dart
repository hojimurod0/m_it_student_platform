import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/chat/domain/entities/chat_message.dart';
import 'package:m_it_student_platform/features/chat/domain/repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository _repository;

  const GetMessagesUseCase({required ChatRepository repository})
      : _repository = repository;

  Future<Result<List<ChatMessage>>> call(String groupId) =>
      _repository.getMessages(groupId);
}
