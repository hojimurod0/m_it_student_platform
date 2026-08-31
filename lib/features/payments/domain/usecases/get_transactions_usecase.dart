import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/payments/domain/entities/payment.dart';
import 'package:m_it_student_platform/features/payments/domain/repositories/payments_repository.dart';

class GetTransactionsUseCase {
  final PaymentsRepository _repository;

  const GetTransactionsUseCase({required PaymentsRepository repository})
      : _repository = repository;

  Future<Result<List<PaymentTransaction>>> call() =>
      _repository.getTransactions();
}
