import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/features/complaints/data/repositories/complaints_repository_impl.dart';

// ── Events ─────────────────────────────────────────────────────────────────

abstract class ComplaintsEvent {
  const ComplaintsEvent();
}

class SubmitComplaintEvent extends ComplaintsEvent {
  const SubmitComplaintEvent({required this.subject, required this.body});
  final String subject;
  final String body;
}

class ResetComplaintEvent extends ComplaintsEvent {
  const ResetComplaintEvent();
}

// ── States ─────────────────────────────────────────────────────────────────

abstract class ComplaintsState {
  const ComplaintsState();
}

class ComplaintsInitial extends ComplaintsState {
  const ComplaintsInitial();
}

class ComplaintsSubmitting extends ComplaintsState {
  const ComplaintsSubmitting();
}

class ComplaintsSuccess extends ComplaintsState {
  const ComplaintsSuccess();
}

class ComplaintsError extends ComplaintsState {
  const ComplaintsError(this.message);
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplaintsError && runtimeType == other.runtimeType && message == other.message;

  @override
  int get hashCode => message.hashCode;
}

// ── BLoC ────────────────────────────────────────────────────────────────────

class ComplaintsBloc extends Bloc<ComplaintsEvent, ComplaintsState> {
  ComplaintsBloc({ComplaintsRepository? repository})
      : _repository = repository ?? ComplaintsRepositoryImpl(),
        super(const ComplaintsInitial()) {
    on<SubmitComplaintEvent>(_onSubmit);
    on<ResetComplaintEvent>(_onReset);
  }

  final ComplaintsRepository _repository;

  Future<void> _onSubmit(SubmitComplaintEvent event, Emitter<ComplaintsState> emit) async {
    emit(const ComplaintsSubmitting());
    try {
      await _repository.submitComplaint(subject: event.subject, body: event.body);
      emit(const ComplaintsSuccess());
    } catch (e) {
      emit(ComplaintsError(e.toString()));
    }
  }

  void _onReset(ResetComplaintEvent event, Emitter<ComplaintsState> emit) {
    emit(const ComplaintsInitial());
  }
}
