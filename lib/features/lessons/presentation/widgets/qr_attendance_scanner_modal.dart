import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';

/// QR Attendance Scanner & Validation Modal for Classroom Check-In
class QrAttendanceScannerModal extends StatefulWidget {
  const QrAttendanceScannerModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QrAttendanceScannerModal(),
    );
  }

  @override
  State<QrAttendanceScannerModal> createState() => _QrAttendanceScannerModalState();
}

class _QrAttendanceScannerModalState extends State<QrAttendanceScannerModal> {
  bool _isScanning = false;
  bool _isSuccess = false;

  void _simulateScan() async {
    setState(() {
      _isScanning = true;
    });
    AppHaptics.medium();
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    setState(() {
      _isScanning = false;
      _isSuccess = true;
    });
    AppHaptics.heavy();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.accentLime : AppColors.brandNavy).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: isDark ? AppColors.accentLime : AppColors.brandNavy,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('qrAttendanceTitle'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          context.tr('qrScanClassroomHint'),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isSuccess) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success.withValues(alpha: isDark ? 0.25 : 0.15),
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Davomat Muvaffaqiyatli Tasdiqlandi!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bugungi Flutter darsiga qatnashingiz qayd etildi.\n+20 M-IT Coin taqdim etildi!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.accentLime : AppColors.brandNavy,
                        foregroundColor: isDark ? AppColors.brandNavy : Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(context.tr('understood')),
                    ),
                  ] else ...[
                    // Scanner Box Frame
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _isScanning
                              ? AppColors.accentLime
                              : (isDark ? AppColors.accentLime : AppColors.brandNavy),
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: _isScanning
                            ? const CircularProgressIndicator(color: AppColors.accentLime)
                            : Icon(
                                Icons.qr_code_2_rounded,
                                size: 120,
                                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isScanning
                          ? 'QR-kod o\'qilmoqda...'
                          : 'Kamerani dars xonasi proyektoridagi QR-kodga qarating',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey.shade300 : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _isScanning ? null : _simulateScan,
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: Text(context.tr('scanQr')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.accentLime : AppColors.brandNavy,
                        foregroundColor: isDark ? AppColors.brandNavy : Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
