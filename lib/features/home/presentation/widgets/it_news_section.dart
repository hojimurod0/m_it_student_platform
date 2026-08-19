import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/widgets/section_header.dart';
import 'package:m_it_student_platform/features/home/data/repositories/it_news_repository.dart';
import 'package:m_it_student_platform/features/home/domain/models/it_news_model.dart';
import 'package:m_it_student_platform/features/home/presentation/widgets/it_news_card.dart';

class ItNewsSection extends StatefulWidget {
  const ItNewsSection({super.key, this.horizontalPadding = 20});

  final double horizontalPadding;

  @override
  State<ItNewsSection> createState() => _ItNewsSectionState();
}

class _ItNewsSectionState extends State<ItNewsSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _categories = ItNewsCategory.values;
  final Map<ItNewsCategory, List<ItNewsArticle>> _articles = {};
  final Map<ItNewsCategory, bool> _loading = {};
  final Map<ItNewsCategory, String?> _errors = {};

  // Search & Bookmarks state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _bookmarkedUrls = {};
  final List<ItNewsArticle> _bookmarkedArticles = [];
  bool _showSavedOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_onTabChange);
    _fetchCategory(_categories[0]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController
      ..removeListener(_onTabChange)
      ..dispose();
    super.dispose();
  }

  void _onTabChange() {
    if (!_tabController.indexIsChanging) return;
    final cat = _categories[_tabController.index];
    if (_articles[cat] == null) {
      _fetchCategory(cat);
    }
  }

  Future<void> _fetchCategory(ItNewsCategory category) async {
    if (!mounted) return;
    setState(() {
      _loading[category] = true;
      _errors[category] = null;
    });

    try {
      final result =
          await ItNewsRepository.instance.fetchArticles(category);
      if (mounted) {
        setState(() {
          _articles[category] = result;
          _loading[category] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errors[category] = e.toString();
          _loading[category] = false;
        });
      }
    }
  }

  void _toggleBookmark(ItNewsArticle article) {
    setState(() {
      if (_bookmarkedUrls.contains(article.url)) {
        _bookmarkedUrls.remove(article.url);
        _bookmarkedArticles.removeWhere((a) => a.url == article.url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maqola saqlanganlardan o\'chirildi'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        _bookmarkedUrls.add(article.url);
        _bookmarkedArticles.add(article);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maqola "Saqlanganlar" ro\'yxatiga qo\'shildi! ⭐️'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _openArticle(BuildContext context, ItNewsArticle article) {
    _showArticleSheet(context, article);
  }

  void _showArticleSheet(BuildContext context, ItNewsArticle article) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isSaved = _bookmarkedUrls.contains(article.url);

          return Container(
            height: MediaQuery.of(context).size.height * 0.82,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Handle
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Rasm / Banner
                if (article.coverImageUrl != null && article.coverImageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    child: Image.network(
                      article.coverImageUrl!,
                      height: 190,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, e, s) => const SizedBox(height: 8),
                    ),
                  ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rasmiy manba & Bookmark Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4.5),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.primaryAccent.withValues(alpha: 0.2)
                                    : AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.primaryAccent.withValues(alpha: 0.4)
                                      : AppColors.primary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 14,
                                    color: isDark
                                        ? AppColors.primaryAccent
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${article.sourceName} • ${article.sourceBadge}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.primaryAccent
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _toggleBookmark(article);
                                setModalState(() {});
                              },
                              icon: Icon(
                                isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                color: isSaved ? AppColors.accentAmber : theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Sarlavha
                        Text(
                          article.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Muallif, Reaksiyalar va Vaqt
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 13,
                              backgroundColor: isDark
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : AppColors.primarySurface,
                              child: Icon(
                                Icons.newspaper_rounded,
                                size: 14,
                                color: isDark
                                    ? AppColors.primaryAccent
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article.authorName,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    article.publishedAt.isNotEmpty
                                        ? article.publishedAt
                                        : 'Yangi maqola',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.favorite_rounded,
                              size: 15,
                              color: AppColors.danger,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${article.reactions}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.timer_outlined,
                              size: 15,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${article.readingTimeMinutes} min',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: theme.colorScheme.outline),
                        const SizedBox(height: 12),

                        // Tavsif
                        Text(
                          article.description.isNotEmpty
                              ? article.description
                              : 'Maqolaning to\'liq matnini rasmiy saytdan o\'qishingiz mumkin.',
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.65,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Amallar tugmalari
                        Row(
                          children: [
                            // Havoladan nusxa olish
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.colorScheme.onSurface,
                                  side: BorderSide(color: theme.colorScheme.outline),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: article.url));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Havola xotiraga nusxalandi!'),
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy_rounded, size: 17),
                                label: const Text(
                                  'Havola nusxasi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Rasmiy saytda o'qish
                            Expanded(
                              flex: 2,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: isDark
                                      ? AppColors.primaryAccent
                                      : AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Rasmiy sayt: ${article.url}'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: isDark
                                          ? AppColors.darkSurfaceSecondary
                                          : AppColors.primary,
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                                label: Text(
                                  '${article.sourceName}da o\'qish',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
          child: SectionHeader(
            title: context.tr('itNewsTitle'),
            subtitle: context.tr('itNewsSub'),
            actionLabel: _showSavedOnly ? 'Barcha yangiliklar' : '⭐️ Saqlanganlar (${_bookmarkedArticles.length})',
            onAction: () {
              setState(() => _showSavedOnly = !_showSavedOnly);
            },
          ),
        ),
        const SizedBox(height: 10),

        // Search Bar Box
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'IT yangiliklari bo\'yicha qidiruv...',
                hintStyle: TextStyle(
                  fontSize: 12.5,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: isDark ? AppColors.primaryAccent : AppColors.primary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // If Saved Tab is Active
        if (_showSavedOnly) ...[
          if (_bookmarkedArticles.isEmpty)
            Container(
              height: 120,
              margin: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bookmark_border_rounded, size: 30, color: AppColors.accentAmber),
                    const SizedBox(height: 6),
                    Text(
                      'Hozircha saqlangan maqolalar yo\'q',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 272,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
                itemCount: _bookmarkedArticles.length,
                separatorBuilder: (_, i) => const SizedBox(width: 12),
                itemBuilder: (context, i) => ItNewsCard(
                  article: _bookmarkedArticles[i],
                  category: ItNewsCategory.all,
                  onTap: () => _openArticle(context, _bookmarkedArticles[i]),
                ),
              ),
            ),
        ] else ...[
          // Tab bar — yoniga scroll (Rasmiy Manbalar)
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
              itemCount: _categories.length,
              separatorBuilder: (_, i) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = _categories[i];
                return AnimatedBuilder(
                  animation: _tabController,
                  builder: (_, w) {
                    final active = _tabController.index == i;
                    return GestureDetector(
                      onTap: () {
                        _tabController.animateTo(i);
                        final c = _categories[i];
                        if (_articles[c] == null) _fetchCategory(c);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: active
                              ? (isDark
                                  ? AppColors.primaryAccent
                                  : AppColors.primary)
                              : (isDark
                                  ? AppColors.darkSurfaceSecondary
                                  : AppColors.surfaceSecondary),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active
                                ? Colors.transparent
                                : (isDark
                                    ? AppColors.darkCardBorder
                                    : AppColors.cardBorder),
                          ),
                        ),
                        child: Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: active
                                ? (isDark
                                    ? AppColors.darkBackground
                                    : Colors.white)
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Maqolalar — horizontal scroll card'lar
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              final cat = _categories[_tabController.index];
              final isLoading = _loading[cat] ?? false;
              final rawArticles = _articles[cat];
              final error = _errors[cat];

              if (isLoading) {
                return _buildLoadingRow(isDark, widget.horizontalPadding);
              }

              if (error != null || rawArticles == null || rawArticles.isEmpty) {
                return _buildEmptyState(context, isDark, cat);
              }

              // Apply Search Filter if query is present
              final articles = _searchQuery.isEmpty
                  ? rawArticles
                  : rawArticles.where((a) {
                      return a.title.toLowerCase().contains(_searchQuery) ||
                          a.description.toLowerCase().contains(_searchQuery) ||
                          a.sourceName.toLowerCase().contains(_searchQuery);
                    }).toList();

              if (articles.isEmpty) {
                return Container(
                  height: 120,
                  margin: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '"$_searchQuery" bo\'yicha yangiliklar topilmadi',
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 272,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
                  itemCount: articles.length,
                  separatorBuilder: (_, i) => const SizedBox(width: 12),
                  itemBuilder: (context, i) => ItNewsCard(
                    article: articles[i],
                    category: cat,
                    onTap: () => _openArticle(context, articles[i]),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingRow(bool isDark, double hp) {
    return SizedBox(
      height: 272,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: hp),
        itemCount: 4,
        separatorBuilder: (_, i) => const SizedBox(width: 12),
        itemBuilder: (_, j) => _SkeletonCard(isDark: isDark),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, bool isDark, ItNewsCategory cat) {
    return Container(
      height: 140,
      margin: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceSecondary
            : AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 36,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              'Rasmiy manbaga ulanishda xatolik yuz berdi',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => _fetchCategory(cat),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Qayta urinish'),
              style: TextButton.styleFrom(
                foregroundColor:
                    isDark ? AppColors.primaryAccent : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Skeleton (loading placeholder) ---
class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard({required this.isDark});
  final bool isDark;

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.isDark
        ? AppColors.darkSurfaceSecondary
        : AppColors.surfaceSecondary;
    final shimmer = widget.isDark
        ? AppColors.darkSurfaceTertiary
        : AppColors.surfaceTertiary;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, w) {
        final color = Color.lerp(base, shimmer, _anim.value)!;
        return Container(
          width: 220,
          decoration: BoxDecoration(
            color: widget.isDark
                ? AppColors.darkSurface
                : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isDark
                  ? AppColors.darkCardBorder
                  : AppColors.cardBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rasm skeleton
              Container(
                height: 126,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 70,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 12,
                        width: 150,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
