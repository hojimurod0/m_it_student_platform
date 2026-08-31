import 'package:m_it_student_platform/features/profile/domain/models/attendance_model.dart';
import 'package:m_it_student_platform/features/profile/domain/models/grade_model.dart';
import 'package:m_it_student_platform/features/profile/domain/models/student_model.dart';

abstract class ProfileRepository {
  Future<StudentProfile> getStudentProfile();
  Future<StudentProfile> updateProfile({
    String? fullName,
    String? phone,
    String? parentPhone,
    String? email,
    String? gender,
    int? avatarIndex,
  });
  Future<List<GradeItem>> getStudentGrades();
  Future<List<AttendanceRecord>> getStudentAttendance();
}
