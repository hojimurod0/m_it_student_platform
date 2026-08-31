import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/features/reviews/presentation/bloc/reviews_bloc.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, this.mentorId, this.mentorName});

  final String? mentorId;
  final String? mentorName;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => ReviewsBloc(),
      child: BlocConsumer<ReviewsBloc, ReviewsState>(
        listener: (context, state) {
          if (state is ReviewsSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${context.tr('reviewSuccess')}'),
                backgroundColor: const Color(0xFF22C55E),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop();
          }
          if (state is ReviewsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
            appBar: AppBar(
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
              elevation: 0,
              title: Text(
                context.tr('rateTeacher'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  if (widget.mentorName != null) ...[
                    Text(
                      widget.mentorName!,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mentor',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Text(
                    context.tr('rateTeacher'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final star = i + 1;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedRating = star),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            star <= _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                            size: 44,
                            color: star <= _selectedRating
                                ? const Color(0xFFFBBF24)
                                : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                          ),
                        ),
                      );
                    }),
                  ),
                  if (_selectedRating > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      _ratingLabel(_selectedRating),
                      style: TextStyle(
                        color: _ratingColor(_selectedRating),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Izohing (ixtiyoriy)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Izoh yozing...',
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceSecondary
                          : AppColors.surfaceSecondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: state is ReviewsSubmitting || _selectedRating == 0
                          ? null
                          : () {
                              context.read<ReviewsBloc>().add(
                                    SubmitReviewEvent(
                                      rating: _selectedRating,
                                      comment: _commentController.text.trim().isEmpty
                                          ? null
                                          : _commentController.text.trim(),
                                      mentorId: widget.mentorId,
                                    ),
                                  );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            isDark ? AppColors.darkSurfaceTertiary : AppColors.surfaceTertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: state is ReviewsSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              context.tr('send'),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1:
        return 'Juda yomon 😞';
      case 2:
        return 'Yomon 😕';
      case 3:
        return 'O\'rtacha 😐';
      case 4:
        return 'Yaxshi 😊';
      case 5:
        return 'Ajoyib! 🌟';
      default:
        return '';
    }
  }

  Color _ratingColor(int r) {
    switch (r) {
      case 1:
      case 2:
        return const Color(0xFFEF4444);
      case 3:
        return const Color(0xFFF59E0B);
      case 4:
        return const Color(0xFF3B82F6);
      case 5:
        return const Color(0xFF22C55E);
      default:
        return AppColors.textMuted;
    }
  }
}
