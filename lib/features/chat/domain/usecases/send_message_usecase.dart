import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/chat/domain/entities/chat_message.dart';
import 'package:m_it_student_platform/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repository;

  const SendMessageUseCase({required ChatRepository repository})
      : _repository = repository;

  Future<Result<ChatMessage>> call(
    String groupId,
    String text, {
    String? attachmentUrl,
  }) =>
      _repository.sendMessage(groupId, text, attachmentUrl: attachmentUrl);
}
