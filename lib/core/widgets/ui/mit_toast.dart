import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';

enum MitToastType {
  info,
  success,
  warning,
  error,
}

class MitToast {
  MitToast._();

  static OverlayEntry? _activeEntry;
  static Timer? _dismissTimer;

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    MitToastType type = MitToastType.info,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    _dismissTimer?.cancel();
    _activeEntry?.remove();
    _activeEntry = null;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    if (type == MitToastType.error) {
      AppHaptics.error();
    } else if (type == MitToastType.success) {
      AppHaptics.success();
    } else {
      AppHaptics.light();
    }

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _TopToastWidget(
        message: message,
        title: title,
        type: type,
        duration: duration,
        onDismissed: () {
          if (_activeEntry == entry) {
            entry.remove();
            _activeEntry = null;
          }
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }

  static void success(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title, type: MitToastType.success);
  }

  static void error(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title, type: MitToastType.error);
  }

  static void warning(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title, type: MitToastType.warning);
  }

  static void info(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title, type: MitToastType.info);
  }
}

class _TopToastWidget extends StatefulWidget {
  const _TopToastWidget({
    required this.message,
    this.title,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final String? title;
  final MitToastType type;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_TopToastWidget> createState() => _TopToastWidgetState();
}

class _TopToastWidgetState extends State<_TopToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      reverseDuration: const Duration(milliseconds: 260),
    );

    _offsetAnim = Tween<Offset>(
      begin: const Offset(0, -1.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    ));

    _scaleAnim = Tween<double>(begin: 0.90, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    ));

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _controller.forward();
    _timer = Timer(widget.duration, _hide);
  }

  void _hide() {
    _timer?.cancel();
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (Color accentColor, IconData icon, String defaultTitle) =
        switch (widget.type) {
      MitToastType.success => (
          const Color(0xFF10B981), // Emerald
          Icons.check_circle_rounded,
          'Muvaffaqiyatli',
        ),
      MitToastType.warning => (
          const Color(0xFFF59E0B), // Amber
          Icons.warning_amber_rounded,
          'Ogohlantirish',
        ),
      MitToastType.error => (
          const Color(0xFFEF4444), // Crimson Red
          Icons.error_rounded,
          'Xatolik',
        ),
      MitToastType.info => (
          isDark ? AppColors.accentLime : AppColors.primary,
          Icons.info_rounded,
          'Ma\'lumot',
        ),
    };

    final titleText = widget.title ?? defaultTitle;

    // Sleek glassmorphic card colors
    final cardBg = isDark
        ? const Color(0xFF131C2E).withValues(alpha: 0.88)
        : Colors.white.withValues(alpha: 0.92);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : const Color(0xFFE2E8F0);

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final bodyColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);

    return Positioned(
      top: topPadding + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.up,
              onDismissed: (_) => widget.onDismissed(),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: _hide,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: borderColor,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: isDark ? 0.22 : 0.12),
                              blurRadius: 24,
                              spreadRadius: 0,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Left Glowing Icon Container
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.16),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: accentColor.withValues(alpha: 0.35),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      icon,
                                      color: accentColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Center Text Column
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          titleText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: titleColor,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          widget.message,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: bodyColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Close Button
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _hide,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white.withValues(alpha: 0.08)
                                              : Colors.black.withValues(alpha: 0.04),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 14,
                                          color: isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
