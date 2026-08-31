import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
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
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _parentPhoneController;
  late final ProfileRepositoryImpl _profileRepo;
  late String _selectedGender;
  late int _selectedAvatarIndex;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _profileRepo = ProfileRepositoryImpl();
    _nameController = TextEditingController(text: widget.student.fullName);
    _phoneController = TextEditingController(text: widget.student.phone);
    _parentPhoneController = TextEditingController(
      text: widget.student.parentPhone,
    );
    _selectedGender = widget.student.gender;
    _selectedAvatarIndex = widget.student.avatarIndex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  bool get _isFemaleSelected =>
      _selectedGender.toLowerCase() == 'female' ||
      _selectedGender.toLowerCase() == 'ayol' ||
      _selectedAvatarIndex == 1;

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      MitToast.warning(context, context.tr('nameRequired'));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _profileRepo.updateProfile(
        fullName: name,
        phone: _phoneController.text.trim(),
        parentPhone: _parentPhoneController.text.trim(),
        gender: _selectedGender,
        avatarIndex: _selectedAvatarIndex,
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

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
                  // ── 1. Avatar tanlash (Sodda va Ixcham) ──
                  Text(
                    context.tr('avatarGender'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      // Erkak
                      Expanded(
                        child: _CompactAvatarButton(
                          isFemale: false,
                          label: context.tr('genderMale'),
                          isSelected: !_isFemaleSelected,
                          onTap: () {
                            setState(() {
                              _selectedGender = 'male';
                              _selectedAvatarIndex = 0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Ayol
                      Expanded(
                        child: _CompactAvatarButton(
                          isFemale: true,
                          label: context.tr('genderFemale'),
                          isSelected: _isFemaleSelected,
                          onTap: () {
                            setState(() {
                              _selectedGender = 'female';
                              _selectedAvatarIndex = 1;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── 2. Ism-familiya ──
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: context.tr('fullName'),
                      labelStyle: TextStyle(
                        color: isDark ? const Color(0xFFCBD5E1) : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        size: 20,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── 3. Telefon raqam ──
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: context.tr('phoneNumber'),
                      labelStyle: TextStyle(
                        color: isDark ? const Color(0xFFCBD5E1) : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        size: 20,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── 4. Ota-ona telefon raqami ──
                  TextField(
                    controller: _parentPhoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: context.tr('parentPhone'),
                      labelStyle: TextStyle(
                        color: isDark ? const Color(0xFFCBD5E1) : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        size: 20,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── 5. O'quv markaz ma'lumotlari (Ixcham) ──
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  const SizedBox(height: 16),

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
                              context.tr('save'),
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

class _CompactAvatarButton extends StatelessWidget {
  const _CompactAvatarButton({
    required this.isFemale,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final bool isFemale;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Uniform, calm selection color without aggressive bright red
    final activeColor = isDark ? AppColors.accentLime : AppColors.brandNavy;
    final iconColor = isDark ? Colors.white : const Color(0xFF00213D);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: isDark ? 0.16 : 0.08)
                : (isDark ? const Color(0xFF1E293B) : AppColors.surfaceSecondary),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Small Circular Avatar (36px) - Uniform clean color
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? activeColor.withValues(alpha: 0.6)
                        : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: GenderAvatarWidget(
                    isFemale: isFemale,
                    size: 26,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Text Label
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.black)
                        : (isDark ? const Color(0xFFCBD5E1) : Colors.black87),
                  ),
                ),
              ),

              if (isSelected) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: activeColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
