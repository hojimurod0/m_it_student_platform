import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/shimmer_loading.dart';
import 'package:m_it_student_platform/features/homework/data/repositories/homework_repository.dart';
import 'package:m_it_student_platform/features/homework/presentation/widgets/submit_homework_modal.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/mock_profile_repository.dart';

class HomeworkModal extends StatefulWidget {
  const HomeworkModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const HomeworkModal(),
    );
  }

  @override
  State<HomeworkModal> createState() => _HomeworkModalState();
}

class _HomeworkModalState extends State<HomeworkModal> {
  late final HomeworkRepository _repository;
  List<HomeworkItem> _homeworks = [];
  bool _isLoading = true;
  int _selectedFilterIndex = 0; // 0: Barchasi, 1: Kutilmoqda, 2: Topshirilgan, 3: Baholangan

  @override
  void initState() {
    super.initState();
    _repository = HomeworkRepository.instance;
    _loadData();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final list = await _repository.getHomeworks(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _homeworks = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _homeworks = _repository.homeworks;
        _isLoading = false;
      });
    }
  }

  List<HomeworkItem> get _filteredHomeworks {
    switch (_selectedFilterIndex) {
      case 1:
        return _homeworks.where((h) => h.status == HomeworkStatus.pending).toList();
      case 2:
        return _homeworks.where((h) => h.status == HomeworkStatus.submitted).toList();
      case 3:
        return _homeworks.where((h) => h.status == HomeworkStatus.reviewed).toList();
      default:
        return _homeworks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pendingCount = _homeworks.where((h) => h.status == HomeworkStatus.pending).length;
    final submittedCount = _homeworks.where((h) => h.status == HomeworkStatus.submitted || h.status == HomeworkStatus.reviewed).length;

    final filterOptions = [
      '${context.tr('all')} (${_homeworks.length})',
      '${context.tr('pending')} ($pendingCount)',
      '${context.tr('submitted')} ($submittedCount)',
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 10),
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.25 : 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.assignment_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr('homeworkTitle'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 1),
                      ValueListenableBuilder(
                        valueListenable: MockProfileRepository.studentNotifier,
                        builder: (context, student, _) {
                          final groupName = student.group.isNotEmpty
                              ? student.group
                              : student.courseName;
                          return Text(
                            '$groupName • ${context.tr('homeworkSub')}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.accentLime
                                  : AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Filter Segmented Buttons
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filterOptions.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedFilterIndex == index;
                return GestureDetector(
                  onTap: () {
                    AppHaptics.selection();
                    setState(() => _selectedFilterIndex = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.accentLime : AppColors.primary)
                          : (isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: Text(
                      filterOptions[index],
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                            : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // Content body
          Expanded(
            child: _buildBody(context, isDark, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark, ThemeData theme) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ShimmerHomeworkListSkeleton(itemCount: 3),
      );
    }

    final items = _filteredHomeworks;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 52,
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('noHomeworksTitle'),
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.tr('noHomeworksSub'),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(forceRefresh: true),
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: items.length,
        separatorBuilder: (_, index) => const SizedBox(height: 14),
        itemBuilder: (context, i) {
          final hw = items[i];
          return _buildHomeworkCard(context, hw, isDark, theme);
        },
      ),
    );
  }

  Widget _buildHomeworkCard(
    BuildContext context,
    HomeworkItem hw,
    bool isDark,
    ThemeData theme,
  ) {
    final isPending = hw.status == HomeworkStatus.pending;
    final isReviewed = hw.status == HomeworkStatus.reviewed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSecondary : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0xFF64748B).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Badges Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hw.course,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.accentLime : AppColors.brandNavy,
                  ),
                ),
              ),
              _buildStatusBadge(hw, isDark),
            ],
          ),
          const SizedBox(height: 10),

          // 2. Title
          Text(
            hw.title,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),

          // 3. Description
          Text(
            hw.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),

          // 4. Deadline Row
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 15,
                color: isPending ? AppColors.accentAmber : (isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              Text(
                '${context.tr('deadlinePrefix')}: ',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                ),
              ),
              Text(
                hw.deadline,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isPending
                      ? (isDark ? const Color(0xFFFDE68A) : const Color(0xFFD97706))
                      : (isDark ? Colors.white : const Color(0xFF1E293B)),
                ),
              ),
            ],
          ),

          // 5. Mentor Review Feedback Box (if reviewed)
          if (isReviewed && hw.mentorFeedback != null && hw.mentorFeedback!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, size: 15, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mentor: ${hw.mentorFeedback}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFFD1FAE5) : const Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 6. Action Button (Submit or Resubmit)
          const SizedBox(height: 12),
          if (isPending) ...[
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () async {
                  AppHaptics.light();
                  await SubmitHomeworkModal.show(
                    context,
                    homeworkId: hw.id,
                    homeworkTitle: hw.title,
                  );
                  _loadData();
                },
                icon: const Icon(Icons.cloud_upload_rounded, size: 17),
                label: Text(
                  context.tr('submitHomeworkBtn'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 36,
              child: OutlinedButton.icon(
                onPressed: () async {
                  AppHaptics.light();
                  await SubmitHomeworkModal.show(
                    context,
                    homeworkId: hw.id,
                    homeworkTitle: hw.title,
                  );
                  _loadData();
                },
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(
                  isReviewed ? context.tr('reloadHomeworkBtn') : context.tr('resubmitHomeworkBtn'),
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.accentLime : AppColors.brandNavy,
                  side: BorderSide(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(HomeworkItem hw, bool isDark) {
    if (hw.status == HomeworkStatus.reviewed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.25 : 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.35),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 14, color: Color(0xFF10B981)),
            const SizedBox(width: 4),
            Text(
              hw.score != null ? '${hw.score} ${context.tr('scorePts')}' : context.tr('graded'),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF10B981),
              ),
            ),
          ],
        ),
      );
    }

    if (hw.status == HomeworkStatus.submitted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.25 : 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_top_rounded, size: 13, color: Color(0xFF3B82F6)),
            const SizedBox(width: 4),
            Text(
              context.tr('submitted'),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.25 : 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule_rounded, size: 13, color: Color(0xFFF59E0B)),
          const SizedBox(width: 4),
          Text(
            context.tr('pending'),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }
}
