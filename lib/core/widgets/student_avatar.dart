import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';

class StudentAvatar extends StatelessWidget {
  const StudentAvatar({
    super.key,
    this.avatarEmoji = '',
    this.initials = 'ST',
    this.gender = 'male',
    this.imageUrl = '',
    this.size = 48,
    this.showOnlineIndicator = false,
    this.showBadge = false,
    this.badgeIcon,
    this.badgeColor,
    this.backgroundColor,
    this.ringColor,
    this.ringGradient,
    this.hasRing = true,
    this.hasGlow = false,
  });

  final String avatarEmoji;
  final String initials;
  final String gender;
  final String imageUrl;
  final double size;
  final bool showOnlineIndicator;
  final bool showBadge;
  final IconData? badgeIcon;
  final Color? badgeColor;
  final Color? backgroundColor;
  final Color? ringColor;
  final Gradient? ringGradient;
  final bool hasRing;
  final bool hasGlow;

  bool get isFemale =>
      gender.toLowerCase() == 'female' ||
      gender.toLowerCase() == 'ayol' ||
      avatarEmoji == '🧕' ||
      avatarEmoji == '👩‍💻';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Gradient ring for modern tech feel
    final defaultGradient = ringGradient ??
        (isDark
            ? const LinearGradient(
                colors: [
                  AppColors.accentLime,
                  Color(0xFF38BDF8), // Cyan tech accent
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [
                  Color(0xFF00213D),
                  Color(0xFF0284C7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ));

    // Sleek inner background gradient for depth
    final innerGradient = backgroundColor != null
        ? null
        : (isDark
            ? const LinearGradient(
                colors: [
                  Color(0xFF1E293B), // Slate 800
                  Color(0xFF0F172A), // Slate 900
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : const LinearGradient(
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFF1F5F9), // Slate 100
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ));

    final padding = hasRing ? (size > 60 ? 3.0 : 2.5) : 0.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // ── Outer Border Ring ──
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasRing ? (ringColor == null ? defaultGradient : null) : null,
              color: hasRing && ringColor != null ? ringColor : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: innerGradient,
                color: backgroundColor,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFF00213D).withValues(alpha: 0.08),
                  width: 0.8,
                ),
              ),
              child: ClipOval(
                child: Center(
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: size,
                          height: size,
                          cacheWidth: (size * 2).toInt(),
                          cacheHeight: (size * 2).toInt(),
                          filterQuality: FilterQuality.medium,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildSilhouette(context),
                        )
                      : _buildSilhouette(context),
                ),
              ),
            ),
          ),

          // ── Optional Status / Online / Action Badge ──
          if (showOnlineIndicator || showBadge)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badgeColor ??
                      (showOnlineIndicator
                          ? const Color(0xFF10B981) // Active Green
                          : (isDark ? AppColors.accentLime : const Color(0xFF00213D))),
                  border: Border.all(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: badgeIcon != null
                    ? Icon(
                        badgeIcon,
                        size: size * 0.16,
                        color: isDark ? const Color(0xFF00213D) : Colors.white,
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSilhouette(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark
        ? Colors.white
        : const Color(0xFF00213D);

    return GenderAvatarWidget(
      isFemale: isFemale,
      size: size,
      color: iconColor,
    );
  }
}

/// Standalone widget for displaying male or female avatar icon
class GenderAvatarWidget extends StatelessWidget {
  const GenderAvatarWidget({
    super.key,
    required this.isFemale,
    this.size = 48,
    this.color,
  });

  final bool isFemale;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = color ??
        (isDark ? Colors.white : const Color(0xFF00213D));

    return Center(
      child: Icon(
        isFemale ? Icons.face_3_rounded : Icons.person_rounded,
        size: size * 0.65,
        color: effectiveColor,
      ),
    );
  }
}


