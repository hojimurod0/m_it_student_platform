import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/features/notifications/presentation/bloc/notifications_bloc.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(const LoadNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('notificationsTitle')),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: context.tr('markAllReadTooltip'),
            onPressed: () {
              // Barcha bildirishnomalarni o'qilgan qilish
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<NotificationsBloc>().add(const LoadNotificationsEvent());
                      },
                      child: Text(context.tr('retry')),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 64,
                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('noNotifications'),
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationsBloc>().add(const LoadNotificationsEvent());
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: state.notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = state.notifications[index];
                  return _NotificationTile(
                    item: item,
                    isDark: isDark,
                    theme: theme,
                    onTap: () {
                      if (!item.isRead) {
                        context
                            .read<NotificationsBloc>()
                            .add(MarkNotificationReadEvent(item.id));
                      }
                      _showNotificationDetails(context, item);
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showNotificationDetails(BuildContext context, InAppNotification item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(item.body),
              const SizedBox(height: 16),
              Text(
                item.createdAt,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.isDark,
    required this.theme,
    required this.onTap,
  });

  final InAppNotification item;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onTap;

  IconData _typeIcon() {
    switch (item.type) {
      case NotificationType.homework:
        return Icons.assignment_rounded;
      case NotificationType.grade:
        return Icons.grade_rounded;
      case NotificationType.payment:
        return Icons.payment_rounded;
      case NotificationType.announcement:
        return Icons.campaign_rounded;
      case NotificationType.chat:
        return Icons.chat_rounded;
      case NotificationType.attendance:
        return Icons.co_present_rounded;
      case NotificationType.info:
      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }

  Color _typeColor() {
    switch (item.type) {
      case NotificationType.homework:
        return const Color(0xFF8B5CF6);
      case NotificationType.grade:
        return const Color(0xFF22C55E);
      case NotificationType.payment:
        return const Color(0xFFF59E0B);
      case NotificationType.announcement:
        return AppColors.secondary;
      case NotificationType.chat:
        return const Color(0xFF3B82F6);
      case NotificationType.attendance:
        return const Color(0xFF10B981);
      case NotificationType.info:
      case NotificationType.general:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: item.isRead ? 0.65 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: !item.isRead
                  ? color.withValues(alpha: 0.4)
                  : (isDark ? AppColors.darkCardBorder : AppColors.cardBorder),
              width: !item.isRead ? 1.5 : 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_typeIcon(), color: color, size: 22),
                ),
                if (!item.isRead)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              item.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  item.message,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.createdAt.length > 10 ? item.createdAt.substring(0, 10) : item.createdAt,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
