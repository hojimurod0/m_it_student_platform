import 'package:m_it_student_platform/core/error/exceptions.dart';
import 'package:m_it_student_platform/core/error/failures.dart';
import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:m_it_student_platform/features/chat/domain/entities/chat_message.dart';
import 'package:m_it_student_platform/features/chat/domain/repositories/chat_repository.dart';

export 'package:m_it_student_platform/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _dataSource;

  ChatRepositoryImpl({required ChatRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<List<ChatMessage>>> getMessages(String groupId) async {
    try {
      final models = await _dataSource.getMessages(groupId);
      return Success(models.map((m) => m.toEntity()).toList());
    } on NetworkException catch (e) {
      return FailureResult(NetworkFailure(e.message, e.cause));
    } on UnauthorizedException catch (e) {
      return FailureResult(UnauthorizedFailure(e.message, e.cause));
    } on ForbiddenException catch (e) {
      return FailureResult(ForbiddenFailure(e.message, e.cause));
    } on NotFoundException catch (e) {
      return FailureResult(NotFoundFailure(e.message, e.cause));
    } on ParseException catch (e) {
      return FailureResult(ParseFailure(e.message, e.cause));
    } on ServerException catch (e) {
      return FailureResult(ServerFailure(e.message, e.cause));
    } catch (e) {
      return FailureResult(UnknownFailure('Xabarlarni olishda kutilmagan xatolik', e));
    }
  }

  @override
  Future<Result<ChatMessage>> sendMessage(String groupId, String text, {String? attachmentUrl}) async {
    try {
      final model = await _dataSource.sendMessage(groupId, text, attachmentUrl: attachmentUrl);
      return Success(model.toEntity());
    } on NetworkException catch (e) {
      return FailureResult(NetworkFailure(e.message, e.cause));
    } on UnauthorizedException catch (e) {
      return FailureResult(UnauthorizedFailure(e.message, e.cause));
    } on ForbiddenException catch (e) {
      return FailureResult(ForbiddenFailure(e.message, e.cause));
    } on NotFoundException catch (e) {
      return FailureResult(NotFoundFailure(e.message, e.cause));
    } on ParseException catch (e) {
      return FailureResult(ParseFailure(e.message, e.cause));
    } on ServerException catch (e) {
      return FailureResult(ServerFailure(e.message, e.cause));
    } catch (e) {
      return FailureResult(UnknownFailure('Xabar yuborishda kutilmagan xatolik', e));
    }
  }
}
