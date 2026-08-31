import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/features/home/domain/models/it_news_model.dart';

class ItNewsCard extends StatelessWidget {
  const ItNewsCard({
    super.key,
    required this.article,
    required this.category,
    required this.onTap,
  });

  final ItNewsArticle article;
  final ItNewsCategory category;
  final VoidCallback onTap;

  String _timeAgo(String iso) {
    if (iso.isEmpty) return 'Yangi';
    try {
      final dt = DateTime.tryParse(iso);
      if (dt == null) return iso.split(' ').first;
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 59)} daq oldin';
      if (diff.inHours < 24) return '${diff.inHours} soat oldin';
      if (diff.inDays < 7) return '${diff.inDays} kun oldin';
      final months = [
        'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyn',
        'Iyl', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek',
      ];
      return '${dt.day} ${months[dt.month - 1]}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkCardBorder : AppColors.cardBorder;
    final meta = _sourceMeta(article.sourceName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Rasm / Banner qismi ──────────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: _ArticleBanner(
                imageUrl: article.coverImageUrl,
                sourceMeta: meta,
                isDark: isDark,
              ),
            ),

            // ── Matn qismi ──────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rasmiy manba chipi (Official Badge)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: meta.chipBg(isDark),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            meta.icon,
                            size: 10.5,
                            color: meta.chipText(isDark),
                          ),
                          const SizedBox(width: 3.5),
                          Flexible(
                            child: Text(
                              article.sourceName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: meta.chipText(isDark),
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.verified_rounded,
                            size: 10,
                            color: meta.chipText(isDark),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 7),

                    // Sarlavha
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        letterSpacing: -0.2,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    const Spacer(),

                    // ── Pastki qator: Reaksiyalar va vaqt ─────────────
                    Row(
                      children: [
                        // ❤ reactions
                        const Icon(
                          Icons.favorite_rounded,
                          size: 11,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${article.reactions}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        // vaqt
                        Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _timeAgo(article.publishedAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.textMuted,
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
      ),
    );
  }

  static _SourceMeta _sourceMeta(String sourceName) {
    final lower = sourceName.toLowerCase();
    if (lower.contains('spot')) {
      return _SourceMeta(
        label: 'Spot.uz',
        icon: Icons.business_center_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        accentColor: const Color(0xFF0D9488),
      );
    } else if (lower.contains('kun')) {
      return _SourceMeta(
        label: 'Kun.uz',
        icon: Icons.public_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        accentColor: const Color(0xFF2563EB),
      );
    } else if (lower.contains('techcrunch')) {
      return _SourceMeta(
        label: 'TechCrunch',
        icon: Icons.electric_bolt_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF065F46), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        accentColor: const Color(0xFF059669),
      );
    } else if (lower.contains('flutter') || lower.contains('google')) {
      return _SourceMeta(
        label: 'Flutter Dev',
        icon: Icons.phone_android_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF0353A4), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        accentColor: const Color(0xFF0284C7),
      );
    } else if (lower.contains('hacker') || lower.contains('ycombinator')) {
      return _SourceMeta(
        label: 'Hacker News',
        icon: Icons.terminal_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFC2410C), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        accentColor: const Color(0xFFEA580C),
      );
    }

    // Default Dev.to yoki boshqa manbalar
    return _SourceMeta(
      label: sourceName.isNotEmpty ? sourceName : 'IT Portal',
      icon: Icons.code_rounded,
      gradient: const LinearGradient(
        colors: [Color(0xFF4C1D95), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentColor: const Color(0xFF7C3AED),
    );
  }
}

// ─── Rasmiy Manba meta ma'lumotlari ─────────────────────────────────────────
class _SourceMeta {
  const _SourceMeta({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.accentColor,
  });

  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final Color accentColor;

  Color chipBg(bool isDark) =>
      isDark ? accentColor.withValues(alpha: 0.22) : accentColor.withValues(alpha: 0.12);

  Color chipText(bool isDark) =>
      isDark ? accentColor.withValues(alpha: 0.95) : accentColor;
}

// ─── Maqola banneri ─────────────────────────────────────────────────────────
class _ArticleBanner extends StatelessWidget {
  const _ArticleBanner({
    required this.imageUrl,
    required this.sourceMeta,
    required this.isDark,
  });

  final String? imageUrl;
  final _SourceMeta sourceMeta;
  final bool isDark;

  static const double _h = 126.0;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Stack(
        children: [
          // Network rasm
          Image.network(
            imageUrl!,
            height: _h,
            width: double.infinity,
            cacheWidth: 440,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return _GradientBanner(meta: sourceMeta, loading: true);
            },
            errorBuilder: (_, e, s) =>
                _GradientBanner(meta: sourceMeta, loading: false),
          ),
          // Yuqorida gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Rasm yo'q → brend gradient banner
    return _GradientBanner(meta: sourceMeta, loading: false);
  }
}

// ─── Gradient banner (placeholder yoki fallback) ─────────────────────────────
class _GradientBanner extends StatelessWidget {
  const _GradientBanner({required this.meta, required this.loading});

  final _SourceMeta meta;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      width: double.infinity,
      decoration: BoxDecoration(gradient: meta.gradient),
      child: Center(
        child: loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    meta.icon,
                    size: 36,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    meta.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
