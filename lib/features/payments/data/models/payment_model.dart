import 'package:json_annotation/json_annotation.dart';
import 'package:m_it_student_platform/features/payments/domain/entities/payment.dart';

part 'payment_model.g.dart';

enum PaymentStatusModel {
  @JsonValue('completed')
  completed,
  @JsonValue('paid')
  paid,
  @JsonValue('pending')
  pending,
  @JsonValue('unpaid')
  unpaid,
  @JsonValue('failed')
  failed,
}

enum PaymentCategoryModel {
  @JsonValue('tuition')
  tuition,
  @JsonValue('course')
  course,
  @JsonValue('material')
  material,
  @JsonValue('exam')
  exam,
  @JsonValue('other')
  other,
}

@JsonSerializable()
class PaymentSummaryModel {
  const PaymentSummaryModel({
    this.monthlyRate = 500000.0,
    this.isPaid = true,
    this.currentMonth = 'Avgust oyi (2026)',
    this.nextDueDate = '1-Sentyabr, 2026',
    this.daysUntilDue = 18,
    this.courseName = 'Back end 05',
    this.totalContract = 500000.0,
    this.amountPaid = 500000.0,
    this.amountRemaining = 0.0,
    this.paidMonths = 1,
    this.totalMonths = 1,
    this.academicYear = 'M-IT Academy',
    this.semester = 'Oylik: 500 000 so\'m',
    this.nextPaymentDueDate,
    this.nextPaymentAmount,
    this.isDebt = false,
  });

  @JsonKey(name: 'monthly_rate', defaultValue: 500000.0)
  final double monthlyRate;
  @JsonKey(name: 'is_paid', defaultValue: true)
  final bool isPaid;
  @JsonKey(name: 'current_month', defaultValue: 'Avgust oyi (2026)')
  final String currentMonth;
  @JsonKey(name: 'next_due_date', defaultValue: '1-Sentyabr, 2026')
  final String nextDueDate;
  @JsonKey(name: 'days_until_due', defaultValue: 18)
  final int daysUntilDue;
  @JsonKey(name: 'course_name', defaultValue: 'Back end 05')
  final String courseName;
  @JsonKey(name: 'total_contract', defaultValue: 500000.0)
  final double totalContract;
  @JsonKey(name: 'amount_paid', defaultValue: 500000.0)
  final double amountPaid;
  @JsonKey(name: 'amount_remaining', defaultValue: 0.0)
  final double amountRemaining;
  @JsonKey(name: 'paid_months', defaultValue: 1)
  final int paidMonths;
  @JsonKey(name: 'total_months', defaultValue: 1)
  final int totalMonths;
  @JsonKey(name: 'academic_year', defaultValue: 'M-IT Academy')
  final String academicYear;
  @JsonKey(name: 'semester', defaultValue: 'Oylik: 500 000 so\'m')
  final String semester;
  @JsonKey(name: 'next_payment_due_date')
  final String? nextPaymentDueDate;
  @JsonKey(name: 'next_payment_amount')
  final double? nextPaymentAmount;
  @JsonKey(name: 'is_debt', defaultValue: false)
  final bool isDebt;

  factory PaymentSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentSummaryModelToJson(this);

  PaymentSummary toEntity() => PaymentSummary(
        monthlyRate: monthlyRate,
        isPaid: isPaid,
        currentMonth: currentMonth,
        nextDueDate: nextDueDate,
        daysUntilDue: daysUntilDue,
        courseName: courseName,
        totalContract: totalContract,
        amountPaid: amountPaid,
        amountRemaining: amountRemaining,
        paidMonths: paidMonths,
        totalMonths: totalMonths,
        academicYear: academicYear,
        semester: semester,
        nextPaymentDueDate: nextPaymentDueDate,
        nextPaymentAmount: nextPaymentAmount,
        isDebt: isDebt,
      );

  factory PaymentSummaryModel.fromEntity(PaymentSummary entity) =>
      PaymentSummaryModel(
        monthlyRate: entity.monthlyRate,
        isPaid: entity.isPaid,
        currentMonth: entity.currentMonth,
        nextDueDate: entity.nextDueDate,
        daysUntilDue: entity.daysUntilDue,
        courseName: entity.courseName,
        totalContract: entity.totalContract,
        amountPaid: entity.amountPaid,
        amountRemaining: entity.amountRemaining,
        paidMonths: entity.paidMonths,
        totalMonths: entity.totalMonths,
        academicYear: entity.academicYear,
        semester: entity.semester,
        nextPaymentDueDate: entity.nextPaymentDueDate,
        nextPaymentAmount: entity.nextPaymentAmount,
        isDebt: entity.isDebt,
      );
}

@JsonSerializable()
class PaymentTransactionModel {
  const PaymentTransactionModel({
    required this.id,
    this.transactionNumber = '',
    required this.amount,
    required this.date,
    this.time = '12:00',
    this.title = 'To\'lov',
    this.status = PaymentStatusModel.completed,
    this.paymentMethod = 'Karta',
    this.category = PaymentCategoryModel.tuition,
    this.payerName = 'Talaba',
    this.recipient = 'M-IT Academy',
    this.notes = '',
    this.receiptNumber,
    this.note,
  });

  final String id;
  @JsonKey(name: 'transaction_number', defaultValue: '')
  final String transactionNumber;
  final double amount;
  final String date;
  @JsonKey(defaultValue: '12:00')
  final String time;
  @JsonKey(defaultValue: 'To\'lov')
  final String title;
  @JsonKey(unknownEnumValue: PaymentStatusModel.completed, defaultValue: PaymentStatusModel.completed)
  final PaymentStatusModel status;
  @JsonKey(name: 'payment_method', defaultValue: 'Karta')
  final String paymentMethod;
  @JsonKey(unknownEnumValue: PaymentCategoryModel.tuition, defaultValue: PaymentCategoryModel.tuition)
  final PaymentCategoryModel category;
  @JsonKey(name: 'payer_name', defaultValue: 'Talaba')
  final String payerName;
  @JsonKey(defaultValue: 'M-IT Academy')
  final String recipient;
  @JsonKey(defaultValue: '')
  final String notes;
  @JsonKey(name: 'receipt_number')
  final String? receiptNumber;
  final String? note;

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    sanitized['id'] = (json['id'] ?? '').toString();
    sanitized['transaction_number'] = json['transaction_number']?.toString() ?? 'TRX-${sanitized['id']}';
    final rawAmount = json['amount'] ?? json['price'] ?? json['paid_amount'] ?? json['monthly_fee'] ?? json['fee'];
    sanitized['amount'] = _parseAmount(rawAmount);
    sanitized['date'] = json['paid_date']?.toString() ?? json['created_at']?.toString() ?? json['date']?.toString() ?? '';
    sanitized['time'] = json['time']?.toString() ?? (json['created_at'] != null && json['created_at'].toString().length >= 16 ? json['created_at'].toString().substring(11, 16) : '18:00');
    sanitized['title'] = json['payment_type_label']?.toString() ?? json['group_name']?.toString() ?? json['title']?.toString() ?? 'Oylik to\'lov';
    sanitized['payment_method'] = json['payment_type_label']?.toString() ?? json['payment_method']?.toString() ?? 'Naqd / Karta';
    sanitized['payer_name'] = json['person_name']?.toString() ?? json['payer_name']?.toString() ?? 'Hojimurod Obidjanov';
    sanitized['recipient'] = json['branch_name']?.toString() ?? json['recipient']?.toString() ?? 'M-IT Academy';
    sanitized['note'] = json['note']?.toString();
    sanitized['notes'] = json['note']?.toString() ?? '';
    if (json['status'] == 'paid' || json['status'] == 'completed') {
      sanitized['status'] = 'completed';
    }
    return _$PaymentTransactionModelFromJson(sanitized);
  }

  Map<String, dynamic> toJson() => _$PaymentTransactionModelToJson(this);

  PaymentTransaction toEntity() => PaymentTransaction(
        id: id,
        transactionNumber: transactionNumber,
        amount: amount,
        date: date,
        time: time,
        title: title,
        status: switch (status) {
          PaymentStatusModel.completed => PaymentStatus.completed,
          PaymentStatusModel.paid => PaymentStatus.paid,
          PaymentStatusModel.pending => PaymentStatus.pending,
          PaymentStatusModel.unpaid => PaymentStatus.unpaid,
          PaymentStatusModel.failed => PaymentStatus.failed,
        },
        paymentMethod: paymentMethod,
        category: switch (category) {
          PaymentCategoryModel.tuition => PaymentCategory.tuition,
          PaymentCategoryModel.course => PaymentCategory.course,
          PaymentCategoryModel.material => PaymentCategory.material,
          PaymentCategoryModel.exam => PaymentCategory.exam,
          PaymentCategoryModel.other => PaymentCategory.other,
        },
        payerName: payerName,
        recipient: recipient,
        notes: notes,
        receiptNumber: receiptNumber,
        note: note,
      );

  factory PaymentTransactionModel.fromEntity(PaymentTransaction entity) =>
      PaymentTransactionModel(
        id: entity.id,
        transactionNumber: entity.transactionNumber,
        amount: entity.amount,
        date: entity.date,
        time: entity.time,
        title: entity.title,
        status: switch (entity.status) {
          PaymentStatus.completed => PaymentStatusModel.completed,
          PaymentStatus.paid => PaymentStatusModel.paid,
          PaymentStatus.pending => PaymentStatusModel.pending,
          PaymentStatus.unpaid => PaymentStatusModel.unpaid,
          PaymentStatus.failed => PaymentStatusModel.failed,
        },
        paymentMethod: entity.paymentMethod,
        category: switch (entity.category) {
          PaymentCategory.tuition => PaymentCategoryModel.tuition,
          PaymentCategory.course => PaymentCategoryModel.course,
          PaymentCategory.material => PaymentCategoryModel.material,
          PaymentCategory.exam => PaymentCategoryModel.exam,
          PaymentCategory.other => PaymentCategoryModel.other,
        },
        payerName: entity.payerName,
        recipient: entity.recipient,
        notes: entity.notes,
        receiptNumber: entity.receiptNumber,
        note: entity.note,
      );
}

double _parseAmount(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  if (val is String) {
    final clean = val.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }
  return 0.0;
}
