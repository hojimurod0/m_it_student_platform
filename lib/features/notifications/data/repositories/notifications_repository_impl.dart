import 'package:m_it_student_platform/core/error/exceptions.dart';
import 'package:m_it_student_platform/core/error/failures.dart';
import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:m_it_student_platform/features/notifications/domain/entities/notification.dart';
import 'package:m_it_student_platform/features/notifications/domain/repositories/notifications_repository.dart';

export 'package:m_it_student_platform/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _dataSource;

  NotificationsRepositoryImpl({required NotificationsRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<List<InAppNotification>>> getNotifications() async {
    try {
      final models = await _dataSource.getNotifications();
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
      return FailureResult(UnknownFailure('Bildirishnomalarni olishda kutilmagan xatolik', e));
    }
  }

  @override
  Future<Result<void>> markAsRead(String id) async {
    try {
      await _dataSource.markAsRead(id);
      return const Success(null);
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
      return FailureResult(UnknownFailure('Bildirishnomani yangilashda kutilmagan xatolik', e));
    }
  }
}
