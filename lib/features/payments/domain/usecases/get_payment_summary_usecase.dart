import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/payments/domain/entities/payment.dart';
import 'package:m_it_student_platform/features/payments/domain/repositories/payments_repository.dart';

class GetPaymentSummaryUseCase {
  final PaymentsRepository _repository;

  const GetPaymentSummaryUseCase({required PaymentsRepository repository})
      : _repository = repository;

  Future<Result<PaymentSummary>> call() => _repository.getPaymentSummary();
}
