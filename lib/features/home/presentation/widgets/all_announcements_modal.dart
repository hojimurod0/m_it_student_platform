import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/features/home/data/repositories/mock_home_repository.dart';
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
  int _selectedFilter = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<String> _buildFilters(BuildContext context) => [
    context.tr('filterAll'),
    context.tr('filterHot'),
    context.tr('filterEvents'),
    context.tr('filterPayments'),
    context.tr('filterExams'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Announcement> _filterAnnouncements() {
    final list = MockHomeRepository.announcements;
    return list.where((item) {
      if (_selectedFilter == 1 && !item.isUrgent) return false;
      if (_selectedFilter == 2 && item.type != AnnouncementType.event) return false;
      if (_selectedFilter == 3 && item.type != AnnouncementType.payment) return false;
      if (_selectedFilter == 4 && item.type != AnnouncementType.exam) return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = item.title.toLowerCase().contains(q);
        final matchMsg = item.message.toLowerCase().contains(q);
        final matchAuthor = item.author.toLowerCase().contains(q);
        if (!matchTitle && !matchMsg && !matchAuthor) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final items = _filterAnnouncements();
    final filters = _buildFilters(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('allAnnouncementsTitle'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${items.length} ${context.tr('announcementsCount')}',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: context.tr('searchPlaceholder'),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(Icons.clear_rounded, size: 18),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SizedBox(
            height: 34,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedFilter == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(filters[index]),
                    labelStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? AppColors.primaryAccent : AppColors.primaryDark)
                          : (isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                    ),
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: isDark
                        ? AppColors.primary.withValues(alpha: 0.25)
                        : AppColors.primarySurface,
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryAccent : theme.colorScheme.outline,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onSelected: (selected) {
                      setState(() => _selectedFilter = index);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: theme.colorScheme.outline),
          const SizedBox(height: 10),

          // Announcements List
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 48,
                          color: isDark ? const Color(0xFF64748B) : AppColors.textMuted,
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
                        const SizedBox(height: 4),
                        Text(
                          context.tr('noAnnouncementsTryAnother'),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return AnnouncementCard(
                        announcement: item,
                        onTap: () => AnnouncementDetailsModal.show(context, item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
