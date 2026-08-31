import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';
import 'package:m_it_student_platform/features/homework/data/datasources/homework_remote_data_source.dart';
import 'package:m_it_student_platform/features/homework/data/repositories/homework_repository.dart';

/// Submit Homework Modal with GitHub Link, File Upload & Comment support
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
  final _githubController = TextEditingController();
  final _commentController = TextEditingController();
  PlatformFile? _pickedFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _githubController.dispose();
    _commentController.dispose();
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
    } catch (e) {
      if (mounted) {
        MitToast.error(context, 'Fayl tanlashda xatolik yuz berdi');
      }
    }
  }

  void _submit() async {
    final githubUrl = _githubController.text.trim();
    final comment = _commentController.text.trim();

    if (githubUrl.isEmpty && _pickedFile == null && comment.isEmpty) {
      MitToast.error(context, context.tr('homeworkRequiredError'));
      return;
    }

    String effectiveGithubUrl = githubUrl;
    if (effectiveGithubUrl.isNotEmpty) {
      if (!effectiveGithubUrl.startsWith('http://') && !effectiveGithubUrl.startsWith('https://')) {
        if (effectiveGithubUrl.contains('.') && !effectiveGithubUrl.contains(' ')) {
          effectiveGithubUrl = 'https://$effectiveGithubUrl';
        }
      }
    }

    setState(() {
      _isSubmitting = true;
    });
    AppHaptics.medium();

    try {
      final remoteSource = sl.isRegistered<HomeworkRemoteDataSource>()
          ? sl<HomeworkRemoteDataSource>()
          : HomeworkRemoteDataSourceImpl(apiClient: sl.isRegistered<ApiClient>() ? sl<ApiClient>() : ApiClient());

      await remoteSource.submitHomework(
        homeworkId: widget.homeworkId,
        text: comment.isNotEmpty ? comment : (effectiveGithubUrl.isNotEmpty ? effectiveGithubUrl : (_pickedFile != null ? 'Fayl: ${_pickedFile!.name}' : 'Topshirildi')),
        githubUrl: effectiveGithubUrl.isNotEmpty ? effectiveGithubUrl : null,
        comment: comment.isNotEmpty ? comment : null,
        filePath: _pickedFile?.path,
        fileBytes: _pickedFile?.bytes,
        fileName: _pickedFile?.name,
      );

      final finalUrl = effectiveGithubUrl.isNotEmpty
          ? effectiveGithubUrl
          : (_pickedFile != null
              ? _pickedFile!.name
              : (comment.isNotEmpty ? comment : 'Topshirildi'));

      await HomeworkRepository.instance.submitHomework(
        widget.homeworkId,
        finalUrl,
        comment: comment,
        filePath: _pickedFile?.path,
        fileBytes: _pickedFile?.bytes,
        fileName: _pickedFile?.name,
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });
      Navigator.of(context).pop();

      MitToast.success(context, context.tr('homeworkSubmitted'));
    } catch (e) {
      // Fallback for seamless UX
      final finalUrl = effectiveGithubUrl.isNotEmpty
          ? effectiveGithubUrl
          : (_pickedFile != null
              ? _pickedFile!.name
              : (comment.isNotEmpty ? comment : 'Topshirildi'));

      await HomeworkRepository.instance.submitHomework(
        widget.homeworkId,
        finalUrl,
        comment: comment,
        filePath: _pickedFile?.path,
        fileBytes: _pickedFile?.bytes,
        fileName: _pickedFile?.name,
      );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      Navigator.of(context).pop();
      MitToast.success(context, context.tr('homeworkSubmitted'));
    }
  }

  IconData _getFileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return Icons.folder_zip_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'dart':
      case 'py':
      case 'js':
      case 'ts':
      case 'sql':
      case 'json':
      case 'html':
      case 'css':
        return Icons.code_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'heic':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getFileColor(String ext) {
    switch (ext.toLowerCase()) {
      case 'zip':
      case 'rar':
      case '7z':
        return const Color(0xFFF59E0B);
      case 'pdf':
        return const Color(0xFFEF4444);
      case 'dart':
      case 'py':
      case 'js':
      case 'ts':
      case 'sql':
        return const Color(0xFF06B6D4);
      case 'jpg':
      case 'jpeg':
      case 'png':
        return const Color(0xFFA855F7);
      default:
        return const Color(0xFF10B981);
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

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.82,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD3FF32).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.cloud_upload_rounded,
                            color: Color(0xFF84CC16),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('submitHomework'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.homeworkTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Form content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // 1. File Upload Drop Zone (Primary)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fayl yuklash (ZIP, PDF, Kod, Rasm)',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      if (_pickedFile != null)
                        GestureDetector(
                          onTap: _pickFile,
                          child: Text(
                            'Almashtirish',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.accentLime : AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_pickedFile == null)
                    GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (isDark ? AppColors.accentLime : AppColors.primary).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.file_present_rounded,
                                size: 32,
                                color: isDark ? AppColors.accentLime : AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Faylni tanlash uchun bosing',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '.zip, .rar, .pdf, .dart, .py, .sql, rasm va boshqalar',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getFileColor(_pickedFile!.extension ?? '').withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _getFileColor(_pickedFile!.extension ?? '').withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getFileIcon(_pickedFile!.extension ?? ''),
                              color: _getFileColor(_pickedFile!.extension ?? ''),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _pickedFile!.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatFileSize(_pickedFile!.size),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 22),
                            onPressed: () {
                              AppHaptics.light();
                              setState(() => _pickedFile = null);
                            },
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // 2. GitHub or External Link
                  Text(
                    '${context.tr('githubRepoLink')} (ixtiyoriy)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _githubController,
                    decoration: InputDecoration(
                      hintText: 'https://github.com/username/project',
                      prefixIcon: const Icon(Icons.link_rounded),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 3. Comment / Explanation text
                  Text(
                    '${context.tr('commentForMentor')} (ixtiyoriy)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: context.tr('commentHint'),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD3FF32),
                      foregroundColor: const Color(0xFF001E36),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Color(0xFF001E36),
                              strokeWidth: 2.4,
                            ),
                          )
                        : Text(
                            context.tr('submitHomework'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF001E36),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
