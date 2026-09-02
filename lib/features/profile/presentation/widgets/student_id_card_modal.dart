import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/utils/phone_formatter.dart';
import 'package:m_it_student_platform/core/widgets/student_avatar.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:m_it_student_platform/features/profile/domain/models/student_model.dart';

/// Oddiy, chiroyli va tushunarli Talaba Guvohnomasi (Student Card)
class StudentIdCardModal extends StatelessWidget {
  const StudentIdCardModal({super.key, this.student});

  final StudentProfile? student;

  static void show(BuildContext context, [StudentProfile? student]) {
    AppHaptics.selection();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StudentIdCardModal(student: student),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = student ?? MockProfileRepository.studentNotifier.value;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF001426) : Colors.white;
    final cardBg = isDark ? const Color(0xFF001E36) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF002F52) : const Color(0xFFE2E8F0);
    final itemBg = isDark ? const Color(0xFF001426) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag Handle ──
            Center(
              child: Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Top Title Row ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD3FF32).withValues(alpha: isDark ? 0.2 : 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.badge_rounded,
                        size: 20,
                        color: Color(0xFFD3FF32),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.tr('digitalStudentCard'),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Clean Student Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColor, width: 1.2),
              ),
              child: Column(
                children: [
                  // 1. Academy Tag & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00213D),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFD3FF32).withValues(alpha: 0.6),
                                width: 1,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'M',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFD3FF32),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'M-IT ACADEMY',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: isDark ? Colors.white : const Color(0xFF00213D),
                            ),
                          ),
                        ],
                      ),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check_circle_rounded, size: 13, color: AppColors.success),
                            SizedBox(width: 5),
                            Text(
                              'Faol talaba',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 2. Avatar & Main Name
                  StudentAvatar(
                    size: 76,
                    avatarEmoji: s.resolvedAvatarEmoji,
                    gender: s.gender,
                    initials: s.initials,
                    hasRing: true,
                    ringColor: const Color(0xFFD3FF32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.fullName.isNotEmpty ? s.fullName : context.tr('student'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Group & Course
                  Text(
                    s.group.isNotEmpty
                        ? '${s.group} • ${s.courseName}'
                        : s.courseName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3. Simple Details Rows
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: itemBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.tag_rounded,
                          iconColor: const Color(0xFFD3FF32),
                          label: 'Talaba ID',
                          value: s.id.isNotEmpty ? s.id : 'MIT-2026-001',
                          isDark: isDark,
                          trailing: GestureDetector(
                            onTap: () {
                              AppHaptics.selection();
                              final copyId = s.id.isNotEmpty ? s.id : 'MIT-2026-001';
                              Clipboard.setData(ClipboardData(text: copyId));
                              MitToast.success(context, '$copyId nusxalandi');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD3FF32).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.copy_rounded,
                                    size: 13,
                                    color: isDark ? const Color(0xFFD3FF32) : const Color(0xFF00213D),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Nusxa',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? const Color(0xFFD3FF32) : const Color(0xFF00213D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (s.mentorName.isNotEmpty) ...[
                          Divider(height: 16, thickness: 0.8, color: borderColor),
                          _buildInfoRow(
                            icon: Icons.person_outline_rounded,
                            iconColor: const Color(0xFF38BDF8),
                            label: 'Ustoz (Mentor)',
                            value: s.mentorName,
                            isDark: isDark,
                          ),
                        ],
                        if (s.classTime.isNotEmpty) ...[
                          Divider(height: 16, thickness: 0.8, color: borderColor),
                          _buildInfoRow(
                            icon: Icons.schedule_rounded,
                            iconColor: const Color(0xFFA78BFA),
                            label: 'Dars vaqti',
                            value: s.classDays.isNotEmpty ? '${s.classTime} (${context.formatScheduleDays(s.classDays)})' : s.classTime,
                            isDark: isDark,
                          ),
                        ],
                        if (s.room.isNotEmpty) ...[
                          Divider(height: 16, thickness: 0.8, color: borderColor),
                          _buildInfoRow(
                            icon: Icons.meeting_room_outlined,
                            iconColor: const Color(0xFFFBBF24),
                            label: 'Xona',
                            value: s.room,
                            isDark: isDark,
                          ),
                        ],
                        if (s.phone.isNotEmpty) ...[
                          Divider(height: 16, thickness: 0.8, color: borderColor),
                          _buildInfoRow(
                            icon: Icons.phone_android_rounded,
                            iconColor: const Color(0xFF34D399),
                            label: 'Telefon',
                            value: formatUzPhone(s.phone),
                            isDark: isDark,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Bottom Close Button ──
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD3FF32),
                  foregroundColor: const Color(0xFF001426),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Tushunarli',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
