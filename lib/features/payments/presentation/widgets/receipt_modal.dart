import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';
import 'package:m_it_student_platform/features/payments/domain/entities/payment.dart';

class ReceiptModal extends StatelessWidget {
  const ReceiptModal({
    super.key,
    required this.transaction,
  });

  final PaymentTransaction transaction;

  static void show(BuildContext context, PaymentTransaction transaction) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReceiptModal(transaction: transaction),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: colorScheme.outline,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header: Success Icon & Official Receipt title
          Center(
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: isDark ? 0.2 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: AppColors.success,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.tr('officialReceipt'),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('financialSystem'),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Receipt Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colorScheme.outline,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Big Amount
                Text(
                  '${_formatCurrency(transaction.amount)} so\'m',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: isDark ? 0.25 : 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    context.tr('verified'),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: colorScheme.outline),
                const SizedBox(height: 10),

                // Detail Rows
                _ReceiptRow(label: context.tr('transactionId'), value: transaction.transactionNumber),
                const SizedBox(height: 8),
                _ReceiptRow(label: context.tr('dateTime'), value: '${transaction.date}, ${transaction.time}'),
                const SizedBox(height: 8),
                _ReceiptRow(label: context.tr('paymentType'), value: transaction.title),
                const SizedBox(height: 8),
                _ReceiptRow(label: context.tr('paymentMethod'), value: transaction.paymentMethod),
                const SizedBox(height: 8),
                _ReceiptRow(label: context.tr('payerName'), value: transaction.payerName),
                const SizedBox(height: 8),
                _ReceiptRow(label: context.tr('recipient'), value: transaction.recipient),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Action Buttons: Download PDF & Share
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    MitToast.success(
                      context,
                      '${context.tr('receiptDownloaded')} (${transaction.transactionNumber}.pdf)',
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 17),
                  label: Text(context.tr('downloadPdf')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    MitToast.info(context, context.tr('receiptLinkCopied'));
                  },
                  icon: const Icon(Icons.share_rounded, size: 17),
                  label: Text(context.tr('shareReceipt')),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
