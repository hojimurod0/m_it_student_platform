// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentSummaryModel _$PaymentSummaryModelFromJson(Map<String, dynamic> json) =>
    PaymentSummaryModel(
      monthlyRate: (json['monthly_rate'] as num?)?.toDouble() ?? 500000.0,
      isPaid: json['is_paid'] as bool? ?? true,
      currentMonth: json['current_month'] as String? ?? 'Avgust oyi (2026)',
      nextDueDate: json['next_due_date'] as String? ?? '1-Sentyabr, 2026',
      daysUntilDue: (json['days_until_due'] as num?)?.toInt() ?? 18,
      courseName: json['course_name'] as String? ?? 'Back end 05',
      totalContract: (json['total_contract'] as num?)?.toDouble() ?? 500000.0,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 500000.0,
      amountRemaining: (json['amount_remaining'] as num?)?.toDouble() ?? 0.0,
      paidMonths: (json['paid_months'] as num?)?.toInt() ?? 1,
      totalMonths: (json['total_months'] as num?)?.toInt() ?? 1,
      academicYear: json['academic_year'] as String? ?? 'M-IT Academy',
      semester: json['semester'] as String? ?? "Oylik: 500 000 so'm",
      nextPaymentDueDate: json['next_payment_due_date'] as String?,
      nextPaymentAmount: (json['next_payment_amount'] as num?)?.toDouble(),
      isDebt: json['is_debt'] as bool? ?? false,
    );

Map<String, dynamic> _$PaymentSummaryModelToJson(
  PaymentSummaryModel instance,
) => <String, dynamic>{
  'monthly_rate': instance.monthlyRate,
  'is_paid': instance.isPaid,
  'current_month': instance.currentMonth,
  'next_due_date': instance.nextDueDate,
  'days_until_due': instance.daysUntilDue,
  'course_name': instance.courseName,
  'total_contract': instance.totalContract,
  'amount_paid': instance.amountPaid,
  'amount_remaining': instance.amountRemaining,
  'paid_months': instance.paidMonths,
  'total_months': instance.totalMonths,
  'academic_year': instance.academicYear,
  'semester': instance.semester,
  'next_payment_due_date': instance.nextPaymentDueDate,
  'next_payment_amount': instance.nextPaymentAmount,
  'is_debt': instance.isDebt,
};

PaymentTransactionModel _$PaymentTransactionModelFromJson(
  Map<String, dynamic> json,
) => PaymentTransactionModel(
  id: json['id'] as String,
  transactionNumber: json['transaction_number'] as String? ?? '',
  amount: (json['amount'] as num).toDouble(),
  date: json['date'] as String,
  time: json['time'] as String? ?? '12:00',
  title: json['title'] as String? ?? "To'lov",
  status:
      $enumDecodeNullable(
        _$PaymentStatusModelEnumMap,
        json['status'],
        unknownValue: PaymentStatusModel.completed,
      ) ??
      PaymentStatusModel.completed,
  paymentMethod: json['payment_method'] as String? ?? 'Karta',
  category:
      $enumDecodeNullable(
        _$PaymentCategoryModelEnumMap,
        json['category'],
        unknownValue: PaymentCategoryModel.tuition,
      ) ??
      PaymentCategoryModel.tuition,
  payerName: json['payer_name'] as String? ?? 'Talaba',
  recipient: json['recipient'] as String? ?? 'M-IT Academy',
  notes: json['notes'] as String? ?? '',
  receiptNumber: json['receipt_number'] as String?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$PaymentTransactionModelToJson(
  PaymentTransactionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'transaction_number': instance.transactionNumber,
  'amount': instance.amount,
  'date': instance.date,
  'time': instance.time,
  'title': instance.title,
  'status': _$PaymentStatusModelEnumMap[instance.status]!,
  'payment_method': instance.paymentMethod,
  'category': _$PaymentCategoryModelEnumMap[instance.category]!,
  'payer_name': instance.payerName,
  'recipient': instance.recipient,
  'notes': instance.notes,
  'receipt_number': instance.receiptNumber,
  'note': instance.note,
};

const _$PaymentStatusModelEnumMap = {
  PaymentStatusModel.completed: 'completed',
  PaymentStatusModel.paid: 'paid',
  PaymentStatusModel.pending: 'pending',
  PaymentStatusModel.unpaid: 'unpaid',
  PaymentStatusModel.failed: 'failed',
};

const _$PaymentCategoryModelEnumMap = {
  PaymentCategoryModel.tuition: 'tuition',
  PaymentCategoryModel.course: 'course',
  PaymentCategoryModel.material: 'material',
  PaymentCategoryModel.exam: 'exam',
  PaymentCategoryModel.other: 'other',
};
