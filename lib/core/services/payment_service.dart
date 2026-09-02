import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:m_it_student_platform/core/utils/app_logger.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';

enum PaymentProvider {
  payme,
  click,
  uzum,
  cashier,
}

class PaymentService {
  PaymentService._();

  // Merchant credentials from environment variables
  static const String paymeMerchantId = String.fromEnvironment('PAYME_MERCHANT_ID', defaultValue: '');
  static const String clickServiceId = String.fromEnvironment('CLICK_SERVICE_ID', defaultValue: '');
  static const String clickMerchantId = String.fromEnvironment('CLICK_MERCHANT_ID', defaultValue: '');

  /// Generates the standard Payme checkout URL
  static String generatePaymeUrl({
    required double amount,
    required String studentId,
    String? description,
  }) {
    final amountInTiyin = (amount * 100).toInt();
    final params = 'm=$paymeMerchantId;ac.student_id=$studentId;a=$amountInTiyin';
    final base64Params = base64Url.encode(utf8.encode(params));
    return 'https://checkout.paycom.uz/$base64Params';
  }

  /// Generates the standard Click checkout URL
  static String generateClickUrl({
    required double amount,
    required String studentId,
  }) {
    final amountInt = amount.toInt();
    return 'https://my.click.uz/services/pay?service_id=$clickServiceId&merchant_id=$clickMerchantId&amount=$amountInt&transaction_param=$studentId';
  }

  /// Generates Uzum Bank payment link
  static String generateUzumUrl({
    required double amount,
    required String studentId,
  }) {
    final amountInt = amount.toInt();
    return 'https://uzumbank.uz/pay?merchant_id=mit_academy&amount=$amountInt&account=$studentId';
  }

  /// Launches the payment checkout
  static Future<bool> launchPayment({
    required BuildContext context,
    required PaymentProvider provider,
    required double amount,
    required String studentId,
  }) async {
    if (provider == PaymentProvider.cashier) {
      _showCashierInfo(context);
      return true;
    }

    if (provider == PaymentProvider.payme && paymeMerchantId.isEmpty) {
      if (context.mounted) {
        MitToast.info(context, 'Payme onlayn to\'lovi sozlanmoqda. Iltimos, ma\'muriyat kassasi orqali to\'lang.');
        _showCashierInfo(context);
      }
      return false;
    }

    if (provider == PaymentProvider.click && (clickServiceId.isEmpty || clickMerchantId.isEmpty)) {
      if (context.mounted) {
        MitToast.info(context, 'Click onlayn to\'lovi sozlanmoqda. Iltimos, ma\'muriyat kassasi orqali to\'lang.');
        _showCashierInfo(context);
      }
      return false;
    }

    final urlString = switch (provider) {
      PaymentProvider.payme => generatePaymeUrl(amount: amount, studentId: studentId),
      PaymentProvider.click => generateClickUrl(amount: amount, studentId: studentId),
      PaymentProvider.uzum => generateUzumUrl(amount: amount, studentId: studentId),
      PaymentProvider.cashier => '',
    };

    try {
      final uri = Uri.parse(urlString);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        if (context.mounted) {
          MitToast.warning(
            context,
            'Brauzer yoki to\'lov ilovasini ochib bo\'lmadi',
          );
        }
        return false;
      }
      return true;
    } catch (e, stack) {
      AppLogger.error('To\'lov havolasini ochishda xatolik: $e', error: e, stackTrace: stack, tag: 'PAYMENT');
      if (context.mounted) {
        MitToast.error(
          context,
          'To\'lov tizimiga ulanishda xatolik yuz berdi',
        );
      }
      return false;
    }
  }

  static void _showCashierInfo(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.storefront_rounded, color: theme.colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'O\'quv Markaz Kassasi',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'O\'quv to\'lovini markazimiz ma\'muriyatida naqd pul, Uzcard/Humo plastik kartasi yoki bank o\'tkazmasi orqali amalga oshirishingiz mumkin.',
              style: TextStyle(fontSize: 13.5, height: 1.5),
            ),
            const SizedBox(height: 14),
            _infoRow(Icons.location_on_outlined, 'Manzil: Toshkent sh., M-IT Bosh ofisi'),
            const SizedBox(height: 8),
            _infoRow(Icons.access_time_rounded, 'Ish vaqti: Dushanba - Shanba, 09:00 - 20:00'),
            const SizedBox(height: 8),
            _infoRow(Icons.phone_outlined, 'Ma\'muriyat: +998 71 200-00-00'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tushundim'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blueAccent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
