import 'package:flutter/foundation.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';
import 'package:m_it_student_platform/features/profile/domain/models/attendance_model.dart';
import 'package:m_it_student_platform/features/profile/domain/models/grade_model.dart';
import 'package:m_it_student_platform/features/profile/domain/models/student_model.dart';

class MockProfileRepository {
  MockProfileRepository._();

  static final ValueNotifier<StudentProfile> studentNotifier = ValueNotifier<StudentProfile>(_getInitialStudent());

  static StudentProfile _getInitialStudent() {
    final saved = LocalStorageService.getUserData();
    if (saved != null) {
      try {
        return StudentProfile.fromJson(saved);
      } catch (_) {}
    }
    return defaultStudent;
  }

  static StudentProfile get currentStudent => studentNotifier.value;

  static const StudentProfile defaultStudent = StudentProfile(
    id: 'ST-10245',
    fullName: 'John Smith',
    phone: '+998 90 123 45 67',
    parentName: 'Ota-onasi',
    parentPhone: '+998 99 876 54 32',
    email: 'john.smith@mit-academy.uz',
    courseName: 'Flutter Mobile Development',
    group: 'FS-204 guruhi',
    mentorName: 'Abbos Qodirov',
    classTime: '14:00 – 16:00',
    classDays: 'Se - Pay - Shan',
    room: 'Google xona',
    monthlyPayment: '500 000 so\'m',
    paymentStatus: 'To\'langan',
    attendancePercentage: 97,
    overallScore: 98,
    coins: 0,
    homeworkPercent: 0,
    gender: 'male',
    avatarIndex: 0,
  );

  static const StudentProfile student = defaultStudent;

  static void setStudent(StudentProfile student) {
    studentNotifier.value = student;
    LocalStorageService.saveUserData(student.toJson());
  }

  static void reset() {
    studentNotifier.value = defaultStudent;
  }

  static void updateProfile({
    String? fullName,
    String? phone,
    String? parentName,
    String? parentPhone,
    String? email,
    String? gender,
    int? avatarIndex,
  }) {
    studentNotifier.value = studentNotifier.value.copyWith(
      fullName: fullName,
      phone: phone,
      parentName: parentName,
      parentPhone: parentPhone,
      email: email,
      gender: gender,
      avatarIndex: avatarIndex,
    );
    LocalStorageService.saveUserData(studentNotifier.value.toJson());
  }

  static const List<GradeItem> grades = [
    GradeItem(
      taskName: 'BLoC Pattern & Clean Architecture Amaliyoti',
      moduleName: 'Flutter Advanced Moduli',
      score: 98,
      gradeLetter: 'A+',
      date: '10-Avgust, 2026',
    ),
    GradeItem(
      taskName: 'REST API & Dio Interceptor Integratsiyasi',
      moduleName: 'Flutter Networking Moduli',
      score: 95,
      gradeLetter: 'A',
      date: '03-Avgust, 2026',
    ),
    GradeItem(
      taskName: 'Custom Paint & Animation Controller',
      moduleName: 'Flutter UI Moduli',
      score: 100,
      gradeLetter: 'A+',
      date: '26-Iyul, 2026',
    ),
    GradeItem(
      taskName: 'Git Branching & GitHub Pull Request',
      moduleName: 'IT Asoslari & DevOps',
      score: 98,
      gradeLetter: 'A+',
      date: '18-Iyul, 2026',
    ),
  ];

  static const List<AttendanceRecord> attendance = [
    AttendanceRecord(
      subject: 'Flutter Mobile Bootcamp (Avgust oyi)',
      attended: 6,
      total: 6,
      percentage: 100,
    ),
    AttendanceRecord(
      subject: 'Flutter Mobile Bootcamp (Iyul oyi)',
      attended: 12,
      total: 12,
      percentage: 100,
    ),
    AttendanceRecord(
      subject: 'IT Asoslari & Git (Iyun oyi)',
      attended: 11,
      total: 12,
      percentage: 92,
    ),
  ];
}
