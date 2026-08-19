enum PaymentStatus {
  paid,
  unpaid,
  pending,
  failed,
}

enum PaymentCategory {
  tuition,
  labAccess,
  examFee,
  certificate,
}

class PaymentSummary {
  const PaymentSummary({
    required this.monthlyRate,
    required this.isPaid,
    required this.currentMonth,
    required this.nextDueDate,
    required this.daysUntilDue,
    required this.courseName,
    this.totalContract = 400000,
    this.amountPaid = 400000,
    this.amountRemaining = 0,
    this.paidMonths = 1,
    this.totalMonths = 1,
    this.academicYear = "M-IT O'quv Markazi",
    this.semester = "Oylik: 400 000 so'm",
  });

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

  String get statusText => isPaid ? "To'langan" : "To'lanmagan";
  double get progressPercentage => isPaid ? 1.0 : 0.0;
  int get remainingMonths => isPaid ? 0 : 1;
}

class PaymentTransaction {
  const PaymentTransaction({
    required this.id,
    required this.transactionNumber,
    required this.amount,
    required this.date,
    required this.time,
    required this.title,
    required this.category,
    required this.status,
    required this.paymentMethod,
    required this.payerName,
    required this.recipient,
    this.notes,
  });

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
  final String? notes;
}
