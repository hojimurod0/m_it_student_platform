import 'package:flutter/foundation.dart';
import 'package:m_it_student_platform/features/profile/domain/models/attendance_model.dart';
import 'package:m_it_student_platform/features/profile/domain/models/grade_model.dart';
import 'package:m_it_student_platform/features/profile/domain/models/student_model.dart';

class MockProfileRepository {
  MockProfileRepository._();

  static final ValueNotifier<StudentProfile> studentNotifier = ValueNotifier<StudentProfile>(student);

  static StudentProfile get currentStudent => studentNotifier.value;

  static const StudentProfile student = StudentProfile(
    id: 'ST-10245',
    fullName: 'John Smith',
    phone: '+998 (90) 123-45-67',
    parentPhone: '+998 (99) 876-54-32',
    email: 'john.smith@mit-academy.uz',
    courseName: 'Flutter Mobile Development',
    group: 'FS-204 guruhi',
    mentorName: 'Abbos Qodirov',
    classTime: '14:00 – 16:00',
    classDays: 'Se - Pay - Shan',
    room: '204-kompyuter xonasi',
    monthlyPayment: '400 000 so\'m',
    paymentStatus: 'To\'langan',
    attendancePercentage: 97,
    overallScore: 98,
    gender: 'male',
    avatarIndex: 0,
  );

  static void updateProfile({
    String? fullName,
    String? phone,
    String? parentPhone,
    String? email,
    String? gender,
    int? avatarIndex,
  }) {
    studentNotifier.value = studentNotifier.value.copyWith(
      fullName: fullName,
      phone: phone,
      parentPhone: parentPhone,
      email: email,
      gender: gender,
      avatarIndex: avatarIndex,
    );
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
