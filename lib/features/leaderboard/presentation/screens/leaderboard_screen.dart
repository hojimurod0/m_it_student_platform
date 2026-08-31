import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/features/leaderboard/presentation/bloc/leaderboard_bloc.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key, required this.groupId, this.myStudentId});

  final String groupId;
  final String? myStudentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LeaderboardBloc>()
        ..add(LoadLeaderboardEvent(groupId: groupId, myStudentId: myStudentId)),
      child: _LeaderboardView(groupId: groupId, myStudentId: myStudentId),
    );
  }
}

class _LeaderboardView extends StatelessWidget {
  const _LeaderboardView({required this.groupId, this.myStudentId});

  final String groupId;
  final String? myStudentId;

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
          context.tr('leaderboardTitle'),
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
            icon: const Icon(Icons.refresh_rounded),
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            onPressed: () => context
                .read<LeaderboardBloc>()
                .add(LoadLeaderboardEvent(groupId: groupId, myStudentId: myStudentId)),
          ),
        ],
      ),
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          if (state is LeaderboardLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryAccent),
            );
          }
          if (state is LeaderboardError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.read<LeaderboardBloc>().add(
                            LoadLeaderboardEvent(groupId: groupId, myStudentId: myStudentId),
                          ),
                      child: Text(context.tr('retry')),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is LeaderboardLoaded) {
            if (state.entries.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events_outlined, size: 56, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(context.tr('noLeaderboard'),
                        style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              );
            }
            return _LeaderboardContent(state: state, isDark: isDark, theme: theme);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LeaderboardContent extends StatelessWidget {
  const _LeaderboardContent({
    required this.state,
    required this.isDark,
    required this.theme,
  });

  final LeaderboardLoaded state;
  final bool isDark;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Podium (top 3)
        if (state.entries.length >= 3)
          SliverToBoxAdapter(
            child: _Podium(top3: state.top3, isDark: isDark),
          ),
        // Rest of list
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final entry = state.entries.length >= 3
                    ? state.entries[i + 3]
                    : state.entries[i];
                return _RankCard(entry: entry, isDark: isDark, theme: theme);
              },
              childCount: state.entries.length >= 3
                  ? state.entries.length - 3
                  : state.entries.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.top3, required this.isDark});

  final List<LeaderboardEntry> top3;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final first = top3[0];
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '🏆 ${context.tr('podiumTitle')}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (second != null)
                _PodiumItem(entry: second, rank: 2, height: 80, medal: '🥈'),
              const SizedBox(width: 12),
              _PodiumItem(entry: first, rank: 1, height: 100, medal: '🥇'),
              const SizedBox(width: 12),
              if (third != null)
                _PodiumItem(entry: third, rank: 3, height: 65, medal: '🥉'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  const _PodiumItem({
    required this.entry,
    required this.rank,
    required this.height,
    required this.medal,
  });

  final LeaderboardEntry entry;
  final int rank;
  final double height;
  final String medal;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(medal, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          CircleAvatar(
            radius: rank == 1 ? 28 : 22,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              entry.studentName.isNotEmpty ? entry.studentName[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: rank == 1 ? 20 : 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            entry.studentName.split(' ').first,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '🪙 ${entry.coins}',
              style: const TextStyle(
                color: AppColors.primaryAccent,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankCard extends StatelessWidget {
  const _RankCard({required this.entry, required this.isDark, required this.theme});

  final LeaderboardEntry entry;
  final bool isDark;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: entry.isMe
            ? AppColors.primaryAccent.withValues(alpha: 0.1)
            : (isDark ? AppColors.darkSurface : AppColors.surface),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: entry.isMe
              ? AppColors.primaryAccent.withValues(alpha: 0.4)
              : (isDark ? AppColors.darkCardBorder : AppColors.cardBorder),
          width: entry.isMe ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceSecondary
                : AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              entry.studentName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            if (entry.isMe) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  context.tr('you'),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Text(
          '🪙 ${entry.coins}',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
