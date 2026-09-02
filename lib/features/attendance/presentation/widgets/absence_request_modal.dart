import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';

/// Modal sheet for submitting an official absence/leave request.
class AbsenceRequestModal extends StatefulWidget {
  const AbsenceRequestModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AbsenceRequestModal(),
    );
  }

  @override
  State<AbsenceRequestModal> createState() => _AbsenceRequestModalState();
}

class _AbsenceRequestModalState extends State<AbsenceRequestModal> {
  final TextEditingController _commentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int _selectedReasonIndex = 0;
  PlatformFile? _attachedDoc;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    AppHaptics.selection();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _attachedDoc = result.files.first);
      }
    } catch (_) {}
  }

  Future<void> _selectDate() async {
    AppHaptics.selection();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (_commentController.text.trim().isEmpty) {
      AppHaptics.error();
      MitToast.warning(context, context.tr('absenceReasonRequired'));
      return;
    }

    setState(() => _isSubmitting = true);
    AppHaptics.success();
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (mounted) {
      Navigator.of(context).pop();
      MitToast.success(context, context.tr('absenceRequestSubmitted'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final reasons = [
      (context.tr('reasonIllness'), Icons.medical_services_outlined),
      (context.tr('reasonFamily'), Icons.people_outline_rounded),
      (context.tr('reasonOther'), Icons.edit_note_rounded),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentLime.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_busy_rounded,
                      color: AppColors.accentLime,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('absenceModalTitle'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          context.tr('absenceModalSubtitle'),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Date Picker Field
              Text(
                context.tr('absenceDateLabel'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 18,
                        color: isDark ? AppColors.accentLime : AppColors.brandNavy,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        context.tr('changeDate'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.accentLime : AppColors.brandNavy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Reason Chips
              Text(
                context.tr('absenceReasonCategory'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(reasons.length, (index) {
                  final (title, icon) = reasons[index];
                  final isSelected = _selectedReasonIndex == index;
                  return ChoiceChip(
                    avatar: Icon(
                      icon,
                      size: 16,
                      color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black54),
                    ),
                    label: Text(title),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        AppHaptics.selection();
                        setState(() => _selectedReasonIndex = index);
                      }
                    },
                    selectedColor: AppColors.accentLime,
                    backgroundColor: isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black87),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Comment / Description
              Text(
                context.tr('absenceExplanation'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                maxLines: 3,
                style: TextStyle(
                  fontSize: 13.5,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: context.tr('absenceHint'),
                  hintStyle: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),

              // Attached Doctor's note or Document
              Text(
                context.tr('absenceAttachDoc'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDocument,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _attachedDoc != null ? Icons.check_circle_rounded : Icons.attach_file_rounded,
                        size: 20,
                        color: _attachedDoc != null
                            ? AppColors.success
                            : (isDark ? AppColors.accentLime : AppColors.brandNavy),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _attachedDoc != null
                              ? '${_attachedDoc!.name} (${(_attachedDoc!.size / 1024).toStringAsFixed(1)} KB)'
                              : context.tr('absenceChooseFile'),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_attachedDoc != null)
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16, color: Colors.redAccent),
                          onPressed: () => setState(() => _attachedDoc = null),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.accentLime : AppColors.brandNavy,
                    foregroundColor: isDark ? AppColors.brandNavy : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? AppColors.brandNavy : Colors.white,
                          ),
                        )
                      : Text(
                          context.tr('sendAbsenceRequest'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
