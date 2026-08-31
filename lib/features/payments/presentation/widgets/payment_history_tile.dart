import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/features/payments/domain/entities/payment.dart';

class PaymentHistoryTile extends StatelessWidget {
  const PaymentHistoryTile({
    super.key,
    required this.transaction,
    this.onViewReceipt,
  });

  final PaymentTransaction transaction;
  final VoidCallback? onViewReceipt;

  String _formatCurrency(double amount) {
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write(' ');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Bugun';
    if (dateStr.contains('T')) {
      final parts = dateStr.split('T');
      return parts.first;
    }
    return dateStr;
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
      case PaymentStatus.completed:
        return AppColors.success;
      case PaymentStatus.pending:
        return AppColors.warning;
      case PaymentStatus.unpaid:
        return AppColors.danger;
      case PaymentStatus.failed:
        return AppColors.danger;
    }
  }

  String _getStatusLabel(BuildContext context, PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
      case PaymentStatus.completed:
        return context.tr('paid');
      case PaymentStatus.unpaid:
        return context.tr('unpaid');
      case PaymentStatus.pending:
        return context.tr('pending');
      case PaymentStatus.failed:
        return context.tr('failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor(transaction.status);
    final isPaid = transaction.status == PaymentStatus.paid ||
        transaction.status == PaymentStatus.completed;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onViewReceipt,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colorScheme.outline),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Payment Status Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isPaid
                      ? Icons.check_circle_rounded
                      : transaction.status == PaymentStatus.pending
                          ? Icons.schedule_rounded
                          : Icons.cancel_rounded,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Title, Date, Payment Method
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      transaction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 3,
                      children: [
                        Text(
                          _formatDate(transaction.date),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : AppColors.textMuted,
                          ),
                        ),
                        if (transaction.time.isNotEmpty)
                          Text(
                            '• ${transaction.time}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          size: 12,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            transaction.paymentMethod.isNotEmpty
                                ? transaction.paymentMethod
                                : 'Naqd / Terminal',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Amount + Status Pill (Resilient & Overflow-proof)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_formatCurrency(transaction.amount)} ${context.tr('currencySom')}',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPaid
                                ? Icons.check
                                : transaction.status == PaymentStatus.pending
                                    ? Icons.access_time
                                    : Icons.close,
                            size: 10,
                            color: statusColor,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              _getStatusLabel(context, transaction.status),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
