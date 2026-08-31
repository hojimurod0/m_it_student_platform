import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';

/// Educational Resources & IT Library Modal
class ResourcesLibraryModal extends StatefulWidget {
  const ResourcesLibraryModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ResourcesLibraryModal(),
    );
  }

  @override
  State<ResourcesLibraryModal> createState() => _ResourcesLibraryModalState();
}

class _ResourcesLibraryModalState extends State<ResourcesLibraryModal> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _resources = const [
    {
      'title': 'Flutter & Dart: To\'liq Cheat-Sheet 2026',
      'category': 'Flutter',
      'size': '4.2 MB',
      'type': 'PDF',
      'icon': Icons.picture_as_pdf_rounded,
      'color': Color(0xFFEF4444),
      'desc': 'Eng ko\'p ishlatiladigan vidjetlar, metodlar va Lifecycle qoidalari.',
    },
    {
      'title': 'BLoC State Management: Amaliy Namunalar',
      'category': 'Flutter',
      'size': '8.5 MB',
      'type': 'ZIP / Repo',
      'icon': Icons.folder_zip_rounded,
      'color': Color(0xFF3B82F6),
      'desc': 'Cubit, Bloc va Clean Architecture uchun tayyor namuna kodi.',
    },
    {
      'title': 'REST API & Postman To\'plami',
      'category': 'Backend',
      'size': '1.8 MB',
      'type': 'JSON',
      'icon': Icons.code_rounded,
      'color': Color(0xFF8B5CF6),
      'desc': 'Barcha API endpointlar va so\'rovlar to\'plami kolleksiyasi.',
    },
    {
      'title': 'Clean Architecture & SOLID tamoyillari',
      'category': 'Dasturlash',
      'size': '12.1 MB',
      'type': 'PPTX',
      'icon': Icons.slideshow_rounded,
      'color': Color(0xFFF59E0B),
      'desc': 'Dastur kodini toza va tartibli tuzish bo\'yicha dars taqdimoti.',
    },
    {
      'title': 'Git & GitHub: Buyruqlar qo\'llanmasi',
      'category': 'Git & DevOps',
      'size': '2.4 MB',
      'type': 'PDF',
      'icon': Icons.terminal_rounded,
      'color': Color(0xFF10B981),
      'desc': 'Branch, commit, pull request va merge buyruqlari cheat-sheet.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final categories = [
      context.tr('all'),
      'Flutter',
      'Backend',
      context.tr('programming'),
      'Git & DevOps',
    ];

    final filteredResources = _selectedCategoryIndex == 0
        ? _resources
        : _resources.where((r) {
            final cat = r['category'];
            if (_selectedCategoryIndex == 1) return cat == 'Flutter';
            if (_selectedCategoryIndex == 2) return cat == 'Backend';
            if (_selectedCategoryIndex == 3) return cat == 'Dasturlash';
            if (_selectedCategoryIndex == 4) return cat == 'Git & DevOps';
            return true;
          }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 10),
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header with safe flexible layout (No RenderFlex overflow)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: isDark ? 0.25 : 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.library_books_rounded,
                    color: AppColors.secondary,
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
                        context.tr('libraryAndResources'),
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
                      Text(
                        context.tr('librarySubtitle'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
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

          // Category Chips Bar
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = index == _selectedCategoryIndex;
                return GestureDetector(
                  onTap: () {
                    AppHaptics.selection();
                    setState(() => _selectedCategoryIndex = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.accentLime : AppColors.brandNavy)
                          : (isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
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

          // Resources List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredResources.length,
              itemBuilder: (context, index) {
                final item = filteredResources[index];
                final color = item['color'] as Color;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceSecondary : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.2)
                            : const Color(0xFF64748B).withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: isDark ? 0.20 : 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: color.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: color,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item['type'] as String,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      item['size'] as String,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item['title'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.onSurface,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (item['desc'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          item['desc'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            AppHaptics.light();
                            MitToast.success(
                              context,
                              '"${item['title']}" muvaffaqiyatli yuklab olindi',
                            );
                          },
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text(
                            'Yuklab olish',
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.accentLime.withValues(alpha: 0.18)
                                : AppColors.primarySurface,
                            foregroundColor: isDark ? AppColors.accentLime : AppColors.primary,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            side: BorderSide(
                              color: isDark
                                  ? AppColors.accentLime.withValues(alpha: 0.4)
                                  : AppColors.primary.withValues(alpha: 0.25),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
