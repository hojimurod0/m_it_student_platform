import 'package:m_it_student_platform/core/error/exceptions.dart';
import 'package:m_it_student_platform/core/error/failures.dart';
import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/payments/data/datasources/payments_remote_data_source.dart';
import 'package:m_it_student_platform/features/payments/domain/entities/payment.dart';
import 'package:m_it_student_platform/features/payments/domain/repositories/payments_repository.dart';

export 'package:m_it_student_platform/features/payments/domain/repositories/payments_repository.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource _dataSource;

  PaymentsRepositoryImpl({required PaymentsRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<PaymentSummary>> getPaymentSummary() async {
    try {
      final model = await _dataSource.getPaymentSummary();
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
      return FailureResult(UnknownFailure('To\'lov ma\'lumotlarini olishda kutilmagan xatolik', e));
    }
  }

  @override
  Future<Result<List<PaymentTransaction>>> getTransactions() async {
    try {
      final models = await _dataSource.getTransactions();
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
      return FailureResult(UnknownFailure('Tranzaksiyalarni olishda kutilmagan xatolik', e));
    }
  }
}
