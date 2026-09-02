import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';
import 'package:m_it_student_platform/features/homework/data/repositories/homework_repository.dart';

/// Minimalist, Clean & Direct Submit Homework Modal
class SubmitHomeworkModal extends StatefulWidget {
  const SubmitHomeworkModal({
    super.key,
    required this.homeworkId,
    required this.homeworkTitle,
  });

  final String homeworkId;
  final String homeworkTitle;

  static Future<void> show(
    BuildContext context, {
    required String homeworkId,
    required String homeworkTitle,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubmitHomeworkModal(
        homeworkId: homeworkId,
        homeworkTitle: homeworkTitle,
      ),
    );
  }

  @override
  State<SubmitHomeworkModal> createState() => _SubmitHomeworkModalState();
}

class _SubmitHomeworkModalState extends State<SubmitHomeworkModal> {
  final _textController = TextEditingController();
  PlatformFile? _pickedFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    AppHaptics.selection();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _pickedFile = result.files.first);
        AppHaptics.light();
      }
    } catch (_) {
      if (mounted) {
        MitToast.error(context, 'Fayl tanlashda xatolik yuz berdi');
      }
    }
  }

  void _submit() async {
    final textInput = _textController.text.trim();

    if (_pickedFile == null && textInput.isEmpty) {
      MitToast.error(context, 'Fayl yuklang yoki izoh/havola kiriting');
      return;
    }

    setState(() => _isSubmitting = true);
    AppHaptics.medium();

    try {
      await HomeworkRepository.instance.submitHomework(
        widget.homeworkId,
        textInput.isNotEmpty ? textInput : (_pickedFile?.name ?? 'Topshirildi'),
        title: widget.homeworkTitle,
        comment: textInput.isNotEmpty ? textInput : null,
        filePath: _pickedFile?.path,
        fileBytes: _pickedFile?.bytes,
        fileName: _pickedFile?.name,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();

      MitToast.success(context, 'Vazifa topshirildi!');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      MitToast.error(
        context,
        'Vazifani yuborishda xatolik yuz berdi. Iltimos qayta urinib ko\'ring.',
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag Handle ──
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Header Title & Close ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.accentLime : AppColors.brandNavy).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'UYGA VAZIFA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: isDark ? AppColors.accentLime : AppColors.brandNavy,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.homeworkTitle.isNotEmpty ? widget.homeworkTitle : 'Vazifani topshirish',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: subtitleColor, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Fayl yuklash ──
            Text(
              'Fayl biriktirish',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),

            if (_pickedFile == null)
              InkWell(
                onTap: _pickFile,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 1.2),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_upload_rounded,
                        size: 28,
                        color: isDark ? AppColors.accentLime : AppColors.brandNavy,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Faylni tanlash',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: (isDark ? AppColors.accentLime : AppColors.primary).withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file_rounded,
                      color: isDark ? AppColors.accentLime : AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _pickedFile!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          Text(
                            _formatFileSize(_pickedFile!.size),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 20),
                      onPressed: () {
                        AppHaptics.light();
                        setState(() => _pickedFile = null);
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 14),

            // ── Izoh yoki Havola ──
            Text(
              'Izoh yoki havola',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 2,
              style: TextStyle(fontSize: 13.5, color: textColor),
              decoration: InputDecoration(
                hintText: 'GitHub havolasi yoki ustoz uchun izoh...',
                hintStyle: TextStyle(
                  fontSize: 12.5,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
                filled: true,
                fillColor: cardBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.accentLime : AppColors.brandNavy,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ── Topshirish Tugmasi ──
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.accentLime : AppColors.brandNavy,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: isDark ? Colors.black : Colors.white,
                          strokeWidth: 2.2,
                        ),
                      )
                    : const Text(
                        'Topshirish',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
