import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/services/payment_service.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/mock_profile_repository.dart';

class CheckoutPaymentModal extends StatefulWidget {
  const CheckoutPaymentModal({super.key, this.initialAmount = 400000});

  final double initialAmount;

  static void show(BuildContext context, {double? initialAmount}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CheckoutPaymentModal(initialAmount: initialAmount ?? 400000),
    );
  }

  @override
  State<CheckoutPaymentModal> createState() => _CheckoutPaymentModalState();
}

class _CheckoutPaymentModalState extends State<CheckoutPaymentModal> {
  int _selectedMethod = 0;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]} ',
          ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }

  void _setAmount(double amount) {
    setState(() {
      _amountController.text = _formatAmount(amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<(String, String, IconData)> paymentMethods = [
      ('Payme Mobile', context.tr('paymeSub'), Icons.phone_android_rounded),
      ('Click Evolution', context.tr('clickSub'), Icons.touch_app_rounded),
      ('Uzum Bank', context.tr('uzumSub'), Icons.account_balance_wallet_rounded),
      (context.tr('studyCenterCashier'), context.tr('cashSub'), Icons.storefront_rounded),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              context.tr('makeTuitionPayment'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.tr('makeTuitionPaymentSub'),
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Preset Monthly Rate Indicator Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primarySurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.primaryAccent.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primaryAccent.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      size: 20,
                      color: isDark ? AppColors.primaryAccent : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('monthlyRateSummary'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatAmount(widget.initialAmount > 0 ? widget.initialAmount : 500000)} ${context.tr('currencySom')} / ${context.tr('monthUnit')}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _setAmount(widget.initialAmount > 0 ? widget.initialAmount : 500000),
                    child: Text(context.tr('select'), style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Amount Input Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: context.tr('paymentAmount'),
                        suffixText: context.tr('currencySom'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              context.tr('paymentMethods'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),

            ...List.generate(paymentMethods.length, (index) {
              final method = paymentMethods[index];
              final isSelected = _selectedMethod == index;

              return GestureDetector(
                onTap: () => setState(() => _selectedMethod = index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.primary.withValues(alpha: 0.25) : AppColors.primarySurface)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? AppColors.primaryAccent : AppColors.primary)
                          : theme.colorScheme.outline,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        method.$3,
                        color: isSelected
                            ? (isDark ? AppColors.primaryAccent : AppColors.primary)
                            : (isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method.$1,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                                color: isSelected
                                    ? (isDark ? AppColors.primaryAccent : AppColors.primaryDark)
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              method.$2,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? const Color(0xFF64748B) : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? AppColors.primaryAccent : AppColors.primary)
                                : theme.colorScheme.outline,
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.all(2.5),
                        child: isSelected
                            ? Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? AppColors.primaryAccent : AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () async {
                final rawAmount = double.tryParse(_amountController.text.replaceAll(' ', '')) ?? widget.initialAmount;
                final studentId = MockProfileRepository.currentStudent.id;
                final provider = switch (_selectedMethod) {
                  0 => PaymentProvider.payme,
                  1 => PaymentProvider.click,
                  2 => PaymentProvider.uzum,
                  _ => PaymentProvider.cashier,
                };

                Navigator.pop(context);

                if (provider != PaymentProvider.cashier) {
                  MitToast.info(
                    context,
                    '${paymentMethods[_selectedMethod].$1} (${_amountController.text} ${context.tr('currencySom')}) ${context.tr('redirectingToPayment')}',
                  );
                }

                await PaymentService.launchPayment(
                  context: context,
                  provider: provider,
                  amount: rawAmount,
                  studentId: studentId,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                '${context.tr('proceedPayment')} (${_amountController.text} ${context.tr('currencySom')})',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
