import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';

/// Highly-optimized, GPU-friendly Shimmer animation using native FadeTransition.
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  final Widget child;
  final bool isLoading;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _opacityAnimation = Tween<double>(begin: 0.45, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    return FadeTransition(
      opacity: _opacityAnimation,
      child: widget.child,
    );
  }
}

/// Helper container box with rounded corners for skeleton loaders.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Pre-built Skeleton Card for Home & Lessons loading states.
class ShimmerCardSkeleton extends StatelessWidget {
  const ShimmerCardSkeleton({super.key, this.height = 140});

  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ShimmerLoading(
      child: Container(
        constraints: BoxConstraints(minHeight: height),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerBox(width: 80, height: 22, borderRadius: 6),
                ShimmerBox(width: 60, height: 22, borderRadius: 6),
              ],
            ),
            const SizedBox(height: 12),
            const ShimmerBox(width: double.infinity, height: 18, borderRadius: 6),
            const SizedBox(height: 8),
            const ShimmerBox(width: 160, height: 14, borderRadius: 6),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerBox(width: 120, height: 14, borderRadius: 6),
                ShimmerBox(width: 80, height: 14, borderRadius: 6),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Pre-built Stat Grid Skeleton for Home Screen
class ShimmerStatGridSkeleton extends StatelessWidget {
  const ShimmerStatGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
        children: List.generate(
          4,
          (index) => const ShimmerBox(
            height: 114,
            borderRadius: 18,
          ),
        ),
      ),
    );
  }
}

/// Pre-built Header Skeleton for Student Avatar & Name
class ShimmerHeaderSkeleton extends StatelessWidget {
  const ShimmerHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Row(
        children: [
          const ShimmerBox(width: 48, height: 48, borderRadius: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                ShimmerBox(width: 140, height: 16, borderRadius: 6),
                SizedBox(height: 6),
                ShimmerBox(width: 90, height: 12, borderRadius: 4),
              ],
            ),
          ),
          const ShimmerBox(width: 40, height: 40, borderRadius: 20),
        ],
      ),
    );
  }
}

/// Pre-built Topic List Skeleton for Lessons Screen
class ShimmerTopicListSkeleton extends StatelessWidget {
  const ShimmerTopicListSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ShimmerLoading(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                const ShimmerBox(width: 42, height: 42, borderRadius: 12),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(width: double.infinity, height: 15, borderRadius: 4),
                      SizedBox(height: 8),
                      ShimmerBox(width: 120, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const ShimmerBox(width: 24, height: 24, borderRadius: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Pre-built Homework List Skeleton for Homework Tab
class ShimmerHomeworkListSkeleton extends StatelessWidget {
  const ShimmerHomeworkListSkeleton({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ShimmerLoading(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerBox(width: 90, height: 22, borderRadius: 12),
                    ShimmerBox(width: 70, height: 20, borderRadius: 10),
                  ],
                ),
                const SizedBox(height: 14),
                const ShimmerBox(width: double.infinity, height: 18, borderRadius: 6),
                const SizedBox(height: 8),
                const ShimmerBox(width: 200, height: 14, borderRadius: 4),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerBox(width: 110, height: 14, borderRadius: 4),
                    ShimmerBox(width: 100, height: 36, borderRadius: 12),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
