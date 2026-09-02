import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/features/home/domain/repositories/home_repository.dart';
import 'package:m_it_student_platform/features/home/domain/models/announcement_model.dart';
import 'package:m_it_student_platform/features/home/presentation/widgets/announcement_card.dart';
import 'package:m_it_student_platform/features/home/presentation/widgets/announcement_details_modal.dart';

class AllAnnouncementsModal extends StatefulWidget {
  const AllAnnouncementsModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AllAnnouncementsModal(),
    );
  }

  @override
  State<AllAnnouncementsModal> createState() => _AllAnnouncementsModalState();
}

class _AllAnnouncementsModalState extends State<AllAnnouncementsModal> {
  late final HomeRepository _homeRepo;
  List<Announcement> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _homeRepo = sl<HomeRepository>();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _homeRepo.getAnnouncements();
      if (mounted) {
        setState(() {
          _items = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final items = _items;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.accentLime : AppColors.brandNavy)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_rounded,
                      color: isDark ? AppColors.accentLime : AppColors.brandNavy,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('notificationsTitle'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${context.tr('allNoticesCount')} (${items.length})',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: theme.colorScheme.outline),
          const SizedBox(height: 14),

          // All Announcements Clean List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 48,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.tr('noAnnouncementsTitle'),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return AnnouncementCard(
                            announcement: item,
                            onTap: () =>
                                AnnouncementDetailsModal.show(context, item),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
