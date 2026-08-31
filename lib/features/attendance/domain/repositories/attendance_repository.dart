import 'package:m_it_student_platform/core/utils/result.dart';
import 'package:m_it_student_platform/features/attendance/domain/entities/attendance.dart';

abstract class AttendanceRepository {
  Future<Result<List<AttendanceRecord>>> getMyAttendance();
}
