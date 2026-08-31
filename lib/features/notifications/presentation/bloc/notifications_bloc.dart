import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/core/error/failures.dart';
import 'package:m_it_student_platform/features/notifications/domain/entities/notification.dart';
import 'package:m_it_student_platform/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:m_it_student_platform/features/notifications/domain/usecases/mark_notification_read_usecase.dart';

export 'package:m_it_student_platform/features/notifications/domain/entities/notification.dart';

// ── Events ─────────────────────────────────────────────────────────────────

sealed class NotificationsEvent {
  const NotificationsEvent();
}

class LoadNotificationsEvent extends NotificationsEvent {
  const LoadNotificationsEvent();
}

class MarkNotificationReadEvent extends NotificationsEvent {
  const MarkNotificationReadEvent(this.notificationId);
  final String notificationId;
}

// ── States ─────────────────────────────────────────────────────────────────

sealed class NotificationsState {
  const NotificationsState();
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded(this.notifications);
  final List<InAppNotification> notifications;

  int get unreadCount => notifications.where((n) => !n.isRead).length;
  List<InAppNotification> get unread => notifications.where((n) => !n.isRead).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationsLoaded && runtimeType == other.runtimeType && notifications == other.notifications;

  @override
  int get hashCode => notifications.hashCode;
}

class NotificationsError extends NotificationsState {
  const NotificationsError({required this.failure, required this.message});
  final Failure failure;
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationsError && runtimeType == other.runtimeType && failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}

// ── BLoC ────────────────────────────────────────────────────────────────────

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({
    required GetNotificationsUseCase getNotificationsUseCase,
    required MarkNotificationReadUseCase markNotificationReadUseCase,
  })  : _getNotificationsUseCase = getNotificationsUseCase,
        _markNotificationReadUseCase = markNotificationReadUseCase,
        super(const NotificationsInitial()) {
    on<LoadNotificationsEvent>(_onLoad);
    on<MarkNotificationReadEvent>(_onMarkRead);
  }

  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;

  Future<void> _onLoad(LoadNotificationsEvent event, Emitter<NotificationsState> emit) async {
    emit(const NotificationsLoading());
    final result = await _getNotificationsUseCase();
    result.when(
      success: (notifications) => emit(NotificationsLoaded(notifications)),
      failure: (failure) => emit(NotificationsError(failure: failure, message: failure.message)),
    );
  }

  Future<void> _onMarkRead(MarkNotificationReadEvent event, Emitter<NotificationsState> emit) async {
    if (state is NotificationsLoaded) {
      final current = (state as NotificationsLoaded).notifications;
      final updated = current.map((n) {
        if (n.id == event.notificationId) return n.copyWith(isRead: true);
        return n;
      }).toList();
      emit(NotificationsLoaded(updated));
      await _markNotificationReadUseCase(event.notificationId);
    }
  }
}
