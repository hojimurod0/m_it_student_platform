import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/payments/domain/entities/payment.dart';

abstract class PaymentsRepository {
  Future<Result<PaymentSummary>> getPaymentSummary();
  Future<Result<List<PaymentTransaction>>> getTransactions();
}
