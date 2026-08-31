import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/features/chat/data/models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatMessageModel>> getMessages(String groupId);
  Future<ChatMessageModel> sendMessage(String groupId, String text, {String? attachmentUrl});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<ChatMessageModel>> getMessages(String groupId) async {
    try {
      final response = await _apiClient.get(AppConfig.groupChat(groupId));

      List<dynamic> rawList = [];
      if (response is List) {
        rawList = response;
      } else if (response is Map && response['results'] is List) {
        rawList = response['results'] as List;
      } else if (response is Map && response['messages'] is List) {
        rawList = response['messages'] as List;
      } else if (response is Map && response['data'] is List) {
        rawList = response['data'] as List;
      } else {
        throw const ParseException('Kutilmagan xabarlar formati');
      }

      return rawList
          .whereType<Map>()
          .map((item) => ChatMessageModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode == 401) throw UnauthorizedException(e.message, e);
      if (e.statusCode == 403) throw ForbiddenException(e.message, e);
      if (e.statusCode == 404) throw NotFoundException(e.message, e);
      throw ServerException(e.message, e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Xabarlarni yuklashda aloqa xatosi', e);
    }
  }

  @override
  Future<ChatMessageModel> sendMessage(String groupId, String text, {String? attachmentUrl}) async {
    try {
      final body = <String, dynamic>{'text': text, 'message': text};
      if (attachmentUrl != null) body['attachment'] = attachmentUrl;

      final response = await _apiClient.post(
        AppConfig.groupChat(groupId),
        body: body,
      );

      if (response is Map<String, dynamic>) {
        return ChatMessageModel.fromJson(response);
      }
      throw const ParseException('Xabar yuborishda noto\'g\'ri javob formati');
    } on ApiException catch (e) {
      if (e.statusCode == 401) throw UnauthorizedException(e.message, e);
      if (e.statusCode == 403) throw ForbiddenException(e.message, e);
      if (e.statusCode == 404) throw NotFoundException(e.message, e);
      throw ServerException(e.message, e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Xabar yuborishda aloqa xatosi', e);
    }
  }
}
