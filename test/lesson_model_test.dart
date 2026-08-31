import 'package:flutter_test/flutter_test.dart';
import 'package:m_it_student_platform/features/lessons/domain/models/lesson_model.dart';

void main() {
  group('Lesson Model Safe Parsing Tests', () {
    test('Correctly parses empty start_time and end_time without fake fallback values', () {
      final json = {
        'id': '101',
        'title': 'Flutter BLoC Masterclass',
        'teacher': 'Javohir Toshmatov',
        'room': '302-xona',
      };

      final lesson = Lesson.fromJson(json);

      expect(lesson.id, equals('101'));
      expect(lesson.subject, equals('Flutter BLoC Masterclass'));
      expect(lesson.teacher, equals('Javohir Toshmatov'));
      expect(lesson.room, equals('302-xona'));
      expect(lesson.startTime, isEmpty);
      expect(lesson.endTime, isEmpty);
    });

    test('Correctly parses nested teacher and room map objects', () {
      final json = {
        'id': 202,
        'subject': 'Python & Django Backend',
        'teacher': {'name': 'Anvar Ergashev', 'role': 'Lead Backend Developer'},
        'room': {'number': '404', 'name': 'Lab A'},
        'start_time': '18:00',
        'end_time': '20:00',
        'status': 'active',
      };

      final lesson = Lesson.fromJson(json);

      expect(lesson.id, equals('202'));
      expect(lesson.teacher, equals('Anvar Ergashev'));
      expect(lesson.room, equals('Lab A'));
      expect(lesson.startTime, equals('18:00'));
      expect(lesson.endTime, equals('20:00'));
      expect(lesson.status, equals(LessonStatus.active));
    });

    test('Correctly parses portal my-groups payload without polluting syllabusTopic with description', () {
      final groupJson = {
        'id': 1,
        'branch': 1,
        'branch_name': 'Bosh filial',
        'course': null,
        'name': 'Back end 05',
        'teacher': 9,
        'teacher_name': "Shohjaxon Jo'rayev",
        'support_teacher': 10,
        'support_teacher_name': 'Musoxon Sardorbekov',
        'room': null,
        'monthly_fee': 500000,
        'course_fee': 600000,
        'schedule': 'DCJ',
        'schedule_label': 'Du, Chor, Juma',
        'lesson_start': '11:00:00',
        'lesson_end': '14:00:00',
        'description': 'Bu guruh back end 05 gruhi',
        'is_active': true,
        'student_count': 1,
      };

      final lesson = Lesson.fromJson(groupJson);

      expect(lesson.subject, equals('Back end 05'));
      expect(lesson.teacher, equals("Shohjaxon Jo'rayev"));
      expect(lesson.supportTeacher, equals('Musoxon Sardorbekov'));
      expect(lesson.description, equals('Bu guruh back end 05 gruhi'));
      expect(lesson.syllabusTopic, isNull);
      expect(lesson.startTime, equals('11:00'));
      expect(lesson.endTime, equals('14:00'));
      expect(lesson.scheduleDays, equals('Du, Chor, Juma'));
      expect(lesson.branchName, equals('Bosh filial'));
    });
  });
}
