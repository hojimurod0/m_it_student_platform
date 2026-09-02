import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/state/app_settings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/shimmer_loading.dart';
import 'package:m_it_student_platform/features/attendance/presentation/bloc/attendance_bloc.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int _selectedFilterIndex = 0; // 0: Barchasi, 1: Kelgan, 2: Kelmagan

  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(const LoadAttendanceEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF8FAFC);
    final appBarBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E2D42) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? Colors.white : AppColors.brandNavy,
          ),
          onPressed: () {
            AppHaptics.light();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          context.tr('attendanceTitle'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: isDark ? Colors.white : AppColors.brandNavy,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderColor, height: 1),
        ),
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                ShimmerCardSkeleton(height: 140),
                SizedBox(height: 14),
                ShimmerCardSkeleton(height: 72),
                SizedBox(height: 10),
                ShimmerCardSkeleton(height: 72),
                SizedBox(height: 10),
                ShimmerCardSkeleton(height: 72),
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
                    Icon(
                      Icons.event_available_rounded,
                      size: 56,
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      context.tr('noAttendance'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }

            final allRecords = state.records;
            final presentRecords = allRecords.where((r) => r.isPresent).toList();
            final absentRecords = allRecords.where((r) => !r.isPresent).toList();

            final filteredRecords = switch (_selectedFilterIndex) {
              1 => presentRecords,
              2 => absentRecords,
              _ => allRecords,
            };

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AttendanceBloc>().add(const LoadAttendanceEvent());
              },
              color: isDark ? AppColors.accentLime : AppColors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // 1. Sleek Attendance Summary Card
                  SliverToBoxAdapter(
                    child: _AttendanceSummary(state: state, isDark: isDark),
                  ),

                  // 2. Filter Pills
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Row(
                        children: [
                          _buildFilterChip(
                            index: 0,
                            label: 'Barchasi (${allRecords.length})',
                            isSelected: _selectedFilterIndex == 0,
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            index: 1,
                            label: 'Kelgan (${presentRecords.length})',
                            isSelected: _selectedFilterIndex == 1,
                            isDark: isDark,
                            activeColor: const Color(0xFF10B981),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            index: 2,
                            label: 'Kelmagan (${absentRecords.length})',
                            isSelected: _selectedFilterIndex == 2,
                            isDark: isDark,
                            activeColor: const Color(0xFFEF4444),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Attendance Cards List
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _AttendanceCard(
                          record: filteredRecords[i],
                          isDark: isDark,
                          theme: theme,
                        ),
                        childCount: filteredRecords.length,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required int index,
    required String label,
    required bool isSelected,
    required bool isDark,
    Color? activeColor,
  }) {
    final effectiveColor = activeColor ?? (isDark ? AppColors.accentLime : AppColors.brandNavy);

    return InkWell(
      onTap: () {
        AppHaptics.selection();
        setState(() => _selectedFilterIndex = index);
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? effectiveColor
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? (isDark && activeColor == null ? Colors.black : Colors.white)
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }
}

class _AttendanceSummary extends StatelessWidget {
  const _AttendanceSummary({required this.state, required this.isDark});

  final AttendanceLoaded state;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final ratePercent = (state.attendanceRate * 100).round();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF001F3D), const Color(0xFF003366)]
              : [const Color(0xFF00274D), const Color(0xFF004480)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFD3FF32).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF001F3D).withValues(alpha: isDark ? 0.5 : 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Circular percentage indicator
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: const Color(0xFFD3FF32),
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$ratePercent%',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFD3FF32),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Davomat Ko\'rsatkichi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      ratePercent >= 80
                          ? 'Ajoyib natija! Darslarga faol qatnashyapsiz 🚀'
                          : 'Darslarni qoldirmaslikka harakat qiling ⚠️',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context.tr('attended'), '${state.presentCount}', const Color(0xFF10B981)),
                Container(width: 1, height: 28, color: Colors.white24),
                _buildStatItem(
                  context.tr('missed'),
                  '${state.totalCount - state.presentCount}',
                  const Color(0xFFEF4444),
                ),
                Container(width: 1, height: 28, color: Colors.white24),
                _buildStatItem(context.tr('lessons'), '${state.totalCount}', Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({
    required this.record,
    required this.isDark,
    required this.theme,
  });

  final AttendanceRecord record;
  final bool isDark;
  final ThemeData theme;

  String _formatDayMonth(BuildContext context, String rawDate) {
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      final lang = context.language;
      final monthsUz = [
        'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
        'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
      ];
      final monthsRu = [
        'Января', 'Февраля', 'Марта', 'Апреля', 'Мая', 'Июня',
        'Июля', 'Августа', 'Сентября', 'Октября', 'Ноября', 'Декабря'
      ];
      final monthsEn = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final list = switch (lang) {
        AppLanguage.ru => monthsRu,
        AppLanguage.en => monthsEn,
        _ => monthsUz,
      };
      return '${dt.day}-${list[dt.month - 1]}, ${dt.year}';
    } catch (_) {
      return rawDate;
    }
  }

  String _formatWeekday(BuildContext context, String rawDate) {
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      final lang = context.language;
      final weekdaysUz = [
        'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba', 'Yakshanba'
      ];
      final weekdaysRu = [
        'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'
      ];
      final weekdaysEn = [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
      ];
      final list = switch (lang) {
        AppLanguage.ru => weekdaysRu,
        AppLanguage.en => weekdaysEn,
        _ => weekdaysUz,
      };
      return list[dt.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPresent = record.isPresent;
    final cardBg = isDark ? const Color(0xFF111927) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E2D42) : const Color(0xFFE2E8F0);
    final statusColor = isPresent ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    final weekday = _formatWeekday(context, record.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPresent
              ? borderColor
              : statusColor.withValues(alpha: isDark ? 0.35 : 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Status Indicator Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.35),
              ),
            ),
            child: Icon(
              isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Left-center: Sana & Hafta kuni
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatDayMonth(context, record.date),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                if (weekday.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    weekday,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right: To'g'risida Kirdi va Chiqdi vaqtlari
          if (isPresent) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Kirdi vaqti
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.18 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.login_rounded, size: 12, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text(
                        '${context.tr('checkinPrefix')}: ${record.checkin ?? "11:00"}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                // Chiqdi vaqti
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.18 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.logout_rounded, size: 12, color: Color(0xFF3B82F6)),
                      const SizedBox(width: 4),
                      Text(
                        '${context.tr('checkoutPrefix')}: ${record.checkout ?? "14:00"}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
              ),
              child: Text(
                context.tr('missed'),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 52, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(context.tr('retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.accentLime : AppColors.brandNavy,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
