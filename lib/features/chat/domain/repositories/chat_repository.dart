import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/chat/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Future<Result<List<ChatMessage>>> getMessages(String groupId);
  Future<Result<ChatMessage>> sendMessage(String groupId, String text, {String? attachmentUrl});
}
