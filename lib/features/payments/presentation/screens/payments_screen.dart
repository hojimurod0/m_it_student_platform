import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/widgets/empty_state_view.dart';
import 'package:m_it_student_platform/core/widgets/section_header.dart';
import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/features/payments/data/repositories/mock_payments_repository.dart';
import 'package:m_it_student_platform/features/payments/domain/entities/payment.dart';
import 'package:m_it_student_platform/features/payments/domain/repositories/payments_repository.dart';
import 'package:m_it_student_platform/core/widgets/shimmer_loading.dart';
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
  late final PaymentsRepository _paymentsRepo;
  PaymentSummary _summary = MockPaymentsRepository.paymentSummary;
  List<PaymentTransaction> _history = MockPaymentsRepository.paymentHistory;
  int _selectedFilterIndex = 0; // 0: All, 1: Paid, 2: Pending
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _paymentsRepo = sl<PaymentsRepository>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadPayments();
    });
  }

  Future<void> _loadPayments() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final summaryResult = await _paymentsRepo.getPaymentSummary();
    final historyResult = await _paymentsRepo.getTransactions();
    if (mounted) {
      setState(() {
        summaryResult.when(
          success: (data) => _summary = data,
          failure: (_) {},
        );
        historyResult.when(
          success: (data) => _history = data,
          failure: (_) {},
        );
        _isLoading = false;
      });
    }
  }

  List<String> _getFilters(BuildContext context) => [
        context.tr('allTransactions'),
        context.tr('paid'),
        context.tr('unpaid'),
      ];

  List<PaymentTransaction> _getFilteredTransactions() {
    switch (_selectedFilterIndex) {
      case 1:
        return _history
            .where((tx) =>
                tx.status == PaymentStatus.paid ||
                tx.status == PaymentStatus.completed)
            .toList();
      case 2:
        return _history
            .where((tx) =>
                tx.status == PaymentStatus.unpaid ||
                tx.status == PaymentStatus.pending ||
                tx.status == PaymentStatus.failed)
            .toList();
      default:
        return _history;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final summary = _summary;
    final transactions = _getFilteredTransactions();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filters = _getFilters(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadPayments,
          color: const Color(0xFFD3FF32),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              // 1. Header Row (Har doim ochiq, Shimmersiz)
              Text(
                context.tr('paymentsTitle'),
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 14),

              // 2. Main Summary Card (Belgilangan 1-shimmer joyi)
              if (_isLoading)
                const ShimmerCardSkeleton(height: 190)
              else
                PaymentSummaryCard(
                  summary: summary,
                ),
              const SizedBox(height: 16),

              // 3. Payment Due Warning Banner (only if debt exists and not loading)
              if (!_isLoading && summary.amountRemaining > 0 && !summary.isPaid) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF451A03).withValues(alpha: 0.5)
                        : AppColors.warningLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.warning.withValues(
                        alpha: isDark ? 0.4 : 0.3,
                      ),
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
                                color: isDark
                                    ? const Color(0xFFFDE68A)
                                    : const Color(0xFF92400E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr('paymentDueMsg'),
                              style: TextStyle(
                                fontSize: 11.5,
                                height: 1.25,
                                color: isDark
                                    ? const Color(0xFFFDE68A).withValues(alpha: 0.85)
                                    : const Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 4. Payment History Section Header (Har doim ochiq, Shimmersiz)
              SectionHeader(
                title: context.tr('paymentHistory'),
                subtitle: context.tr('paymentHistorySub'),
              ),
              const SizedBox(height: 12),

              // History Filter Chips (Har doim ochiq, Shimmersiz)
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
                        showCheckmark: false,
                        label: Text(filters[index]),
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? const Color(0xFF94A3B8)
                                  : AppColors.textSecondary),
                        ),
                        backgroundColor: isDark
                            ? theme.colorScheme.surface
                            : Colors.white,
                        selectedColor: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                        side: BorderSide(
                          color: isSelected
                              ? (isDark
                                  ? AppColors.primaryAccent
                                  : AppColors.primary)
                              : (isDark
                                  ? theme.colorScheme.outline
                                  : const Color(0xFFE2E8F0)),
                          width: isSelected ? 1.2 : 1.0,
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

              // 5. Transaction Items (Belgilangan 2-shimmer joyi)
              if (_isLoading)
                const ShimmerTopicListSkeleton(itemCount: 3)
              else if (transactions.isEmpty)
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
        ),
      ),
    );
  }
}
