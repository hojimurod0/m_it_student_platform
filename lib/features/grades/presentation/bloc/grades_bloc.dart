import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/core/error/failures.dart';
import 'package:m_it_student_platform/features/grades/domain/entities/grade.dart';
import 'package:m_it_student_platform/features/grades/domain/usecases/get_my_grades_usecase.dart';

export 'package:m_it_student_platform/features/grades/domain/entities/grade.dart';

// ── Events ─────────────────────────────────────────────────────────────────

sealed class GradesEvent {
  const GradesEvent();
}

class LoadGradesEvent extends GradesEvent {
  const LoadGradesEvent();
}

// ── States ─────────────────────────────────────────────────────────────────

sealed class GradesState {
  const GradesState();
}

class GradesInitial extends GradesState {
  const GradesInitial();
}

class GradesLoading extends GradesState {
  const GradesLoading();
}

class GradesLoaded extends GradesState {
  const GradesLoaded(this.grades);
  final List<GradeItem> grades;

  int get totalCoins => grades.fold(0, (sum, g) => sum + g.coins);
  double get averageScore {
    if (grades.isEmpty) return 0;
    return grades.fold(0.0, (sum, g) => sum + g.percentage) / grades.length;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradesLoaded && runtimeType == other.runtimeType && grades == other.grades;

  @override
  int get hashCode => grades.hashCode;
}

class GradesError extends GradesState {
  const GradesError({required this.failure, required this.message});
  final Failure failure;
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradesError && runtimeType == other.runtimeType && failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}

// ── BLoC ────────────────────────────────────────────────────────────────────

class GradesBloc extends Bloc<GradesEvent, GradesState> {
  GradesBloc({required GetMyGradesUseCase getMyGradesUseCase})
      : _getMyGradesUseCase = getMyGradesUseCase,
        super(const GradesInitial()) {
    on<LoadGradesEvent>(_onLoad);
  }

  final GetMyGradesUseCase _getMyGradesUseCase;

  Future<void> _onLoad(LoadGradesEvent event, Emitter<GradesState> emit) async {
    emit(const GradesLoading());
    final result = await _getMyGradesUseCase();
    result.when(
      success: (grades) => emit(GradesLoaded(grades)),
      failure: (failure) => emit(GradesError(failure: failure, message: failure.message)),
    );
  }
}
