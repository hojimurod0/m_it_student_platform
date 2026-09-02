import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/core/error/failures.dart';
import 'package:m_it_student_platform/features/attendance/domain/entities/attendance.dart';
import 'package:m_it_student_platform/features/attendance/domain/usecases/get_my_attendance_usecase.dart';

export 'package:m_it_student_platform/features/attendance/domain/entities/attendance.dart';

// ── Events ─────────────────────────────────────────────────────────────────

sealed class AttendanceEvent {
  const AttendanceEvent();
}

class LoadAttendanceEvent extends AttendanceEvent {
  const LoadAttendanceEvent();
}

// ── States ─────────────────────────────────────────────────────────────────

sealed class AttendanceState {
  const AttendanceState();
}

class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

class AttendanceLoading extends AttendanceState {
  const AttendanceLoading();
}

class AttendanceLoaded extends AttendanceState {
  const AttendanceLoaded(this.records);
  final List<AttendanceRecord> records;

  int get presentCount => records.where((r) => r.isPresent).length;
  int get absentCount => records.where((r) => !r.isPresent).length;
  int get totalCount => records.length;
  double get attendanceRate => totalCount > 0 ? presentCount / totalCount : 1.0;
  double get attendancePercentage => attendanceRate * 100;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceLoaded && runtimeType == other.runtimeType && records == other.records;

  @override
  int get hashCode => records.hashCode;
}

class AttendanceError extends AttendanceState {
  const AttendanceError({required this.failure, required this.message});
  final Failure failure;
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceError && runtimeType == other.runtimeType && failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}

// ── BLoC ────────────────────────────────────────────────────────────────────

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc({required GetMyAttendanceUseCase getMyAttendanceUseCase})
      : _getMyAttendanceUseCase = getMyAttendanceUseCase,
        super(const AttendanceInitial()) {
    on<LoadAttendanceEvent>(_onLoad);
  }

  final GetMyAttendanceUseCase _getMyAttendanceUseCase;

  Future<void> _onLoad(LoadAttendanceEvent event, Emitter<AttendanceState> emit) async {
    emit(const AttendanceLoading());
    final result = await _getMyAttendanceUseCase();
    result.when(
      success: (records) => emit(AttendanceLoaded(records)),
      failure: (failure) => emit(AttendanceError(failure: failure, message: failure.message)),
    );
  }
}
