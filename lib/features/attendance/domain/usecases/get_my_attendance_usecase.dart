import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/attendance/domain/entities/attendance.dart';
import 'package:m_it_student_platform/features/attendance/domain/repositories/attendance_repository.dart';

class GetMyAttendanceUseCase {
  final AttendanceRepository _repository;

  const GetMyAttendanceUseCase({required AttendanceRepository repository})
      : _repository = repository;

  Future<Result<List<AttendanceRecord>>> call() => _repository.getMyAttendance();
}
