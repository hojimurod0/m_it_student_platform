import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/widgets/shimmer_loading.dart';
import 'package:m_it_student_platform/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:m_it_student_platform/features/attendance/presentation/widgets/absence_request_modal.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(const LoadAttendanceEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        elevation: 0,
        title: Text(
          context.tr('attendanceTitle'),
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
        actions: [
          IconButton(
            tooltip: context.tr('absenceModalTitle'),
            icon: const Icon(Icons.event_busy_rounded, color: AppColors.accentLime),
            onPressed: () => AbsenceRequestModal.show(context),
          ),
        ],
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                ShimmerCardSkeleton(height: 120),
                SizedBox(height: 12),
                ShimmerCardSkeleton(height: 80),
                ShimmerCardSkeleton(height: 80),
                ShimmerCardSkeleton(height: 80),
              ],
            );
          }
          if (state is AttendanceError) {
            return _AttendanceError(
              message: state.message,
              onRetry: () => context.read<AttendanceBloc>().add(const LoadAttendanceEvent()),
            );
          }
          if (state is AttendanceLoaded) {
            if (state.records.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.face_rounded, size: 56, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(context.tr('noAttendance'),
                        style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              );
            }
            return _AttendanceList(state: state, isDark: isDark, theme: theme);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _AttendanceList extends StatelessWidget {
  const _AttendanceList({required this.state, required this.isDark, required this.theme});

  final AttendanceLoaded state;
  final bool isDark;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _AttendanceSummary(state: state, isDark: isDark),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _AttendanceCard(
                record: state.records[i],
                isDark: isDark,
                theme: theme,
              ),
              childCount: state.records.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _AttendanceSummary extends StatelessWidget {
  const _AttendanceSummary({required this.state, required this.isDark});

  final AttendanceLoaded state;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final rate = (state.attendanceRate * 100).toStringAsFixed(0);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: state.attendanceRate >= 0.8
              ? [const Color(0xFF16A34A), const Color(0xFF15803D)]
              : state.attendanceRate >= 0.6
                  ? [const Color(0xFFD97706), const Color(0xFFB45309)]
                  : [const Color(0xFFDC2626), const Color(0xFFB91C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
              const SizedBox(height: 6),
              Text('$rate%',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
              Text(context.tr('attendance'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          Container(width: 1, height: 50, color: Colors.white30),
          Column(
            children: [
              const Icon(Icons.event_available_rounded, color: Colors.white, size: 24),
              const SizedBox(height: 6),
              Text('${state.presentCount}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
              Text(context.tr('attended'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          Container(width: 1, height: 50, color: Colors.white30),
          Column(
            children: [
              const Icon(Icons.event_busy_rounded, color: Colors.white, size: 24),
              const SizedBox(height: 6),
              Text('${state.totalCount - state.presentCount}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
              Text(context.tr('missed'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.record, required this.isDark, required this.theme});

  final AttendanceRecord record;
  final bool isDark;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isPresent = record.isPresent;
    final color = isPresent ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    String typeIcon;
    switch (record.type) {
      case AttendanceType.faceId:
        typeIcon = '🤳';
      case AttendanceType.qr:
        typeIcon = '📷';
      case AttendanceType.manual:
        typeIcon = '✍️';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isPresent ? Icons.check_rounded : Icons.close_rounded,
            color: color,
          ),
        ),
        title: Text(
          record.date.length > 10 ? record.date.substring(0, 10) : record.date,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        subtitle: record.hasCheckin
            ? Text(
                '$typeIcon  ${context.tr('checkinPrefix')}: ${record.checkin ?? '-'}'
                '${record.hasCheckout ? '  •  ${context.tr('checkoutPrefix')}: ${record.checkout}' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              )
            : Text(
                context.tr('missed'),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
        trailing: Text(
          isPresent ? '✓' : '✗',
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _AttendanceError extends StatelessWidget {
  const _AttendanceError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.tr('retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
