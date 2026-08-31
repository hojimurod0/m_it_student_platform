enum PaymentStatus {
  completed,
  paid,
  pending,
  unpaid,
  failed,
}

enum PaymentCategory {
  tuition,
  course,
  material,
  exam,
  other,
}

/// Pure Domain Entity: To'lov xulosasi
class PaymentSummary {
  final double monthlyRate;
  final bool isPaid;
  final String currentMonth;
  final String nextDueDate;
  final int daysUntilDue;
  final String courseName;
  final double totalContract;
  final double amountPaid;
  final double amountRemaining;
  final int paidMonths;
  final int totalMonths;
  final String academicYear;
  final String semester;
  final String? nextPaymentDueDate;
  final double? nextPaymentAmount;
  final bool isDebt;

  const PaymentSummary({
    this.monthlyRate = 500000,
    this.isPaid = true,
    this.currentMonth = 'Avgust oyi (2026)',
    this.nextDueDate = '1-Sentyabr, 2026',
    this.daysUntilDue = 18,
    this.courseName = 'Back end 05',
    this.totalContract = 500000,
    this.amountPaid = 500000,
    this.amountRemaining = 0,
    this.paidMonths = 1,
    this.totalMonths = 1,
    this.academicYear = 'M-IT Academy',
    this.semester = 'Oylik: 500 000 so\'m',
    this.nextPaymentDueDate,
    this.nextPaymentAmount,
    this.isDebt = false,
  });

  double get paymentPercentage =>
      totalContract > 0 ? (amountPaid / totalContract).clamp(0.0, 1.0) : 0.0;

  String get statusText => isPaid ? 'To\'langan' : 'To\'lanmagan';
}

/// Pure Domain Entity: To'lov tranzaksiyasi
class PaymentTransaction {
  final String id;
  final String transactionNumber;
  final double amount;
  final String date;
  final String time;
  final String title;
  final PaymentCategory category;
  final PaymentStatus status;
  final String paymentMethod;
  final String payerName;
  final String recipient;
  final String notes;
  final String? receiptNumber;
  final String? note;

  const PaymentTransaction({
    required this.id,
    this.transactionNumber = '',
    required this.amount,
    required this.date,
    this.time = '12:00',
    this.title = 'To\'lov',
    this.category = PaymentCategory.tuition,
    this.status = PaymentStatus.completed,
    this.paymentMethod = 'Payme Mobile',
    this.payerName = 'Talaba',
    this.recipient = 'M-IT Academy',
    this.notes = '',
    this.receiptNumber,
    this.note,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentTransaction && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
