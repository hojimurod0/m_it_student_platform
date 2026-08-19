import 'package:m_it_student_platform/features/home/domain/models/announcement_model.dart';
import 'package:m_it_student_platform/features/lessons/domain/models/lesson_model.dart';

class MockHomeRepository {
  MockHomeRepository._();

  static const Lesson featuredClass = Lesson(
    id: 'les-01',
    subject: 'Flutter Mobile Development',
    courseCode: 'FLUT-401',
    teacher: 'Abbos Qodirov',
    teacherRole: 'Senior Flutter Lead & Mentor',
    startTime: '14:00',
    endTime: '16:00',
    room: '204-kompyuter xonasi',
    building: 'A-bino, 2-qavat',
    status: LessonStatus.upcoming,
    date: '13-Avgust, 2026',
    dayOfWeek: 'Payshanba',
    scheduleDays: 'Se - Pay - Shan',
    track: LessonTrack.flutter,
    syllabusTopic: 'BLoC Pattern, Clean Architecture va REST API integratsiyasi',
    notes: 'O\'quv markaz kompyuterlarida barcha kerakli dasturlar tayyorlangan.',
    startsInText: '14:00 da boshlanadi',
    durationMinutes: 120,
  );

  static const List<Announcement> announcements = [
    Announcement(
      id: 'ann-01',
      title: 'M-IT O\'quv Markazi Xakatoni: Frontend, Backend & Flutter',
      message: 'Markazimiz o\'quvchilari uchun 48-soatlik amaliy dasturlash musobaqasi! Jamoalar real IT loyihalar yaratadi.',
      type: AnnouncementType.event,
      date: '12-Avgust, 2026',
      time: '10:00',
      author: 'M-IT O\'quv Bo\'limi',
      isUrgent: true,
      actionLabel: 'Xakatonga ro\'yxatdan o\'tish',
    ),
    Announcement(
      id: 'ann-02',
      title: 'Oylik Kurs To\'lovi Eslatmasi (400 000 so\'m)',
      message: 'Hurmatli o\'quvchi, keyingi oy uchun 400 000 so\'m to\'lov 1-Sentyabrgacha qabul qilinadi. To\'lovni Payme, Click yoki kassa orqali amalga oshirishingiz mumkin.',
      type: AnnouncementType.payment,
      date: '11-Avgust, 2026',
      time: '16:15',
      author: 'M-IT Moliya Bo\'limi',
      isUrgent: false,
      actionLabel: 'To\'lov qilish',
    ),
    Announcement(
      id: 'ann-03',
      title: 'Amaliy Laboratoriya Mashg\'ulotlari Eslatmasi',
      message: 'Darsdan tashqari vaqtlarda 204-kompyuter xonasida amaliyot qilish uchun ma\'muriyatga murojaat qilishingiz mumkin.',
      type: AnnouncementType.assignment,
      date: '09-Avgust, 2026',
      time: '14:30',
      author: 'Abbos Qodirov (Lead Mentor)',
      isUrgent: true,
      actionLabel: 'Lab xonasini band qilish',
    ),
    Announcement(
      id: 'ann-04',
      title: 'Kompyuter Savodxonligi & IT Asoslari Amaliy Imtihoni',
      message: 'Linux terminal buyruqlari, tarmoq asoslari va Git bo\'yicha amaliy imtihon juma kuni 102-xonada bo\'lib o\'tadi.',
      type: AnnouncementType.exam,
      date: '08-Avgust, 2026',
      time: '11:20',
      author: 'Nodirbek Alimov (IT Mentor)',
      isUrgent: false,
      actionLabel: 'Qoidalarni o\'qish',
    ),
  ];
}
