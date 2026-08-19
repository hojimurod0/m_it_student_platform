import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/empty_state_view.dart';
import 'package:m_it_student_platform/core/widgets/section_header.dart';
import 'package:m_it_student_platform/features/payments/data/repositories/mock_payments_repository.dart';
import 'package:m_it_student_platform/features/payments/domain/models/payment_model.dart';
import 'package:m_it_student_platform/features/payments/presentation/widgets/checkout_payment_modal.dart';
import 'package:m_it_student_platform/features/payments/presentation/widgets/payment_history_tile.dart';
import 'package:m_it_student_platform/features/payments/presentation/widgets/payment_summary_card.dart';
import 'package:m_it_student_platform/features/payments/presentation/widgets/receipt_modal.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with AutomaticKeepAliveClientMixin {
  int _selectedFilterIndex = 0; // 0: All, 1: Paid, 2: Pending

  @override
  bool get wantKeepAlive => true;

  List<String> _getFilters(BuildContext context) => [
        context.tr('allTransactions'),
        context.tr('paid'),
        context.tr('unpaid'),
      ];

  List<PaymentTransaction> _getFilteredTransactions() {
    switch (_selectedFilterIndex) {
      case 1:
        return MockPaymentsRepository.paymentHistory
            .where((tx) => tx.status == PaymentStatus.paid)
            .toList();
      case 2:
        return MockPaymentsRepository.paymentHistory
            .where((tx) => tx.status == PaymentStatus.unpaid || tx.status == PaymentStatus.pending)
            .toList();
      default:
        return MockPaymentsRepository.paymentHistory;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    const summary = MockPaymentsRepository.paymentSummary;
    final transactions = _getFilteredTransactions();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filters = _getFilters(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            AppHaptics.light();
            await Future<void>.delayed(const Duration(milliseconds: 350));
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
            // 1. Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('paymentsTitle'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('paymentsSubtitle'),
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.file_download_outlined, size: 20, color: theme.colorScheme.onSurface),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Oylik o\'quv to\'lovlari ko\'chirmasi yuklab olindi.')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 2. Main Summary Card (Monthly 400 000 so'm / Paid / Unpaid)
            PaymentSummaryCard(
              summary: summary,
              onPayNow: () => CheckoutPaymentModal.show(context, initialAmount: 400000),
            ),
            const SizedBox(height: 16),

            // 3. Payment Due Warning Banner
            if (summary.amountRemaining > 0) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF451A03).withValues(alpha: 0.5)
                      : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: isDark ? 0.4 : 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('paymentDueSoon'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr('paymentDueMsg'),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFFFDE68A).withValues(alpha: 0.8) : const Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => CheckoutPaymentModal.show(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.warning : const Color(0xFF92400E),
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        context.tr('payNow'),
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // 4. Quick Payment Actions
            SectionHeader(title: context.tr('quickActions')),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ActionChipButton(
                    icon: Icons.add_card_rounded,
                    label: context.tr('makePayment'),
                    color: AppColors.primary,
                    onTap: () => CheckoutPaymentModal.show(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionChipButton(
                    icon: Icons.receipt_long_rounded,
                    label: context.tr('downloadAll'),
                    color: AppColors.secondary,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Barcha to\'lov cheklari yuklab olinmoqda...')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionChipButton(
                    icon: Icons.support_agent_rounded,
                    label: context.tr('support'),
                    color: AppColors.accentPurple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('O\'quv markazi hisobxonasiga ulanmoqda...')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // 5. Payment History Section
            SectionHeader(
              title: context.tr('paymentHistory'),
              subtitle: context.tr('paymentHistorySub'),
            ),
            const SizedBox(height: 12),

            // History Filter Chips
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilterIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(filters[index]),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? (isDark ? AppColors.primaryAccent : AppColors.primaryDark)
                            : (isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                      ),
                      backgroundColor: theme.colorScheme.surface,
                      selectedColor: isDark
                          ? AppColors.primary.withValues(alpha: 0.25)
                          : AppColors.primarySurface,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryAccent
                            : theme.colorScheme.outline,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onSelected: (selected) {
                        setState(() => _selectedFilterIndex = index);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // Transaction Items or Empty State
            if (transactions.isEmpty)
              EmptyStateView(
                title: context.tr('noPaymentsTitle'),
                message: context.tr('noPaymentsMessage'),
                icon: Icons.receipt_long_outlined,
                actionLabel: context.tr('showAllTransactions'),
                onAction: () => setState(() => _selectedFilterIndex = 0),
              )
            else
              ...transactions.map((tx) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PaymentHistoryTile(
                    transaction: tx,
                    onViewReceipt: () => ReceiptModal.show(context, tx),
                  ),
                );
              }),
          ],
        ),
      )),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = (isDark &&
            (color == AppColors.primary ||
                color == AppColors.brandNavy ||
                color == const Color(0xFF00213D) ||
                color == const Color(0xFF001426)))
        ? AppColors.accentLime
        : color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outline),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: isDark ? 0.25 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: effectiveColor),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
