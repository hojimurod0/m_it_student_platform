import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/utils/phone_formatter.dart';
import 'package:m_it_student_platform/core/widgets/student_avatar.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:m_it_student_platform/features/profile/domain/models/student_model.dart';

class EditProfileModal extends StatefulWidget {
  const EditProfileModal({super.key, required this.student});

  final StudentProfile student;

  static void show(BuildContext context, StudentProfile student) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileModal(student: student),
    );
  }

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  late final TextEditingController _phoneController;
  late final ProfileRepositoryImpl _profileRepo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _profileRepo = ProfileRepositoryImpl();
    _phoneController = TextEditingController(
      text: formatUzPhone(widget.student.phone),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    AppHaptics.selection();
    final rawPhone = _phoneController.text.trim();
    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 9) {
      MitToast.warning(context, "Telefon raqamini to'liq kiriting");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final formattedPhone = formatUzPhone(rawPhone);
      await _profileRepo.updateProfile(
        phone: formattedPhone,
      );

      if (!mounted) return;
      Navigator.pop(context);
      MitToast.success(context, context.tr('profileUpdated'));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      MitToast.error(context, e.toString().replaceAll('Exception:', '').trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isFemale = widget.student.gender.toLowerCase() == 'female' ||
        widget.student.gender.toLowerCase() == 'ayol' ||
        widget.student.avatarIndex == 1;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('editProfile'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 22,
                  color: isDark ? Colors.white : Colors.black,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. Admin tomonidan boshqarilishi haqida eslatma ──
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 20,
                          color: isDark ? AppColors.accentLime : AppColors.brandNavy,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            context.tr('adminManagedInfo'),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── 2. Talaba ma'lumotlari (Ism, Jins - Read-Only) ──
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        StudentAvatar(
                          size: 46,
                          hasRing: false,
                          avatarEmoji: widget.student.resolvedAvatarEmoji,
                          gender: widget.student.gender,
                          initials: widget.student.initials,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.student.fullName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    size: 14,
                                    color: isDark
                                        ? const Color(0xFF64748B)
                                        : AppColors.textMuted,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isFemale ? "Ayol • Talaba" : "Erkak • Talaba",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            context.tr('adminOnlyBadge'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : AppColors.accentPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── 3. Talaba Telefon raqami (Tahrirlanadigan maydon) ──
                  Text(
                    context.tr('phoneNumber'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [UzPhoneInputFormatter()],
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    decoration: InputDecoration(
                      hintText: '+998 90 123 45 67',
                      hintStyle: TextStyle(
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(
                        Icons.phone_android_rounded,
                        size: 20,
                        color: isDark ? AppColors.accentLime : AppColors.brandNavy,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.accentLime
                              : AppColors.brandNavy,
                          width: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── 4. Ota-ona ma'lumotlari (Read-Only) ──
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B).withValues(alpha: 0.4)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.family_restroom_rounded,
                                  size: 16,
                                  color: AppColors.accentPurple,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  context.tr('parentPhone'),
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFFCBD5E1)
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 14,
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : AppColors.textMuted,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (widget.student.parentName.isNotEmpty) ...[
                          _SimpleInfoRow(
                            label: "${context.tr('parentName')}:",
                            value: widget.student.parentName,
                          ),
                          const SizedBox(height: 4),
                        ],
                        _SimpleInfoRow(
                          label: "${context.tr('phoneNumber')}:",
                          value: widget.student.parentPhone.isNotEmpty
                              ? formatUzPhone(widget.student.parentPhone)
                              : context.tr('notSpecified'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── 5. O'quv markaz ma'lumotlari (Ixcham) ──
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Column(
                      children: [
                        _SimpleInfoRow(
                          label: '${context.tr('group')}:',
                          value: widget.student.group.isNotEmpty
                              ? widget.student.group
                              : widget.student.courseName,
                        ),
                        const SizedBox(height: 4),
                        _SimpleInfoRow(
                          label: '${context.tr('mentor')}:',
                          value: widget.student.mentorName,
                        ),
                        const SizedBox(height: 4),
                        _SimpleInfoRow(
                          label: '${context.tr('room')}:',
                          value: widget.student.room,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── 6. Saqlash tugmasi ──
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.accentLime : AppColors.brandNavy,
                        foregroundColor: isDark ? const Color(0xFF00213D) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark ? const Color(0xFF00213D) : Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              context.tr('saveChanges'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleInfoRow extends StatelessWidget {
  const _SimpleInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFCBD5E1) : Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
