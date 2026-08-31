import 'package:m_it_student_platform/features/payments/domain/entities/payment.dart';

class MockPaymentsRepository {
  static const PaymentSummary paymentSummary = PaymentSummary(
    monthlyRate: 500000,
    isPaid: true,
    currentMonth: 'Avgust oyi (2026)',
    nextDueDate: '1-Sentyabr, 2026',
    daysUntilDue: 18,
    courseName: 'Back end 05',
    totalContract: 500000,
    amountPaid: 500000,
    amountRemaining: 0,
    paidMonths: 1,
    totalMonths: 1,
    academicYear: 'M-IT Academy',
    semester: 'Oylik: 500 000 so\'m',
  );

  static const List<PaymentTransaction> paymentHistory = [
    PaymentTransaction(
      id: 'TXN-8904',
      transactionNumber: 'MIT-2026-8904',
      amount: 500000,
      date: '1-Avgust, 2026',
      time: '14:22',
      title: 'Avgust oyi to\'lovi',
      category: PaymentCategory.tuition,
      status: PaymentStatus.paid,
      paymentMethod: 'Payme Mobile',
      payerName: 'Hojimurod Obidjanov',
      recipient: 'M-IT Academy',
      notes: 'Avgust oyi uchun 500 000 so\'m oylik to\'lov muvaffaqiyatli qabul qilindi.',
    ),
    PaymentTransaction(
      id: 'TXN-8120',
      transactionNumber: 'MIT-2026-8120',
      amount: 500000,
      date: '1-Iyul, 2026',
      time: '11:15',
      title: 'Iyul oyi to\'lovi',
      category: PaymentCategory.tuition,
      status: PaymentStatus.paid,
      paymentMethod: 'Click Evolution',
      payerName: 'Hojimurod Obidjanov',
      recipient: 'M-IT Academy',
      notes: 'Iyul oyi uchun 500 000 so\'m oylik to\'lov qabul qilindi.',
    ),
    PaymentTransaction(
      id: 'TXN-9012',
      transactionNumber: 'MIT-2026-9012',
      amount: 500000,
      date: '1-Sentyabr, 2026',
      time: '09:00',
      title: 'Sentyabr oyi to\'lovi',
      category: PaymentCategory.tuition,
      status: PaymentStatus.unpaid,
      paymentMethod: 'To\'lov qilinmagan',
      payerName: 'Hojimurod Obidjanov',
      recipient: 'M-IT Academy',
      notes: 'Keyingi oy uchun 500 000 so\'m to\'lov 1-Sentyabrgacha amalga oshirilishi lozim.',
    ),
  ];
}
