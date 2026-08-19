import 'package:m_it_student_platform/features/homework/domain/models/homework_model.dart';

class HomeworkRepository {
  HomeworkRepository._();

  static final HomeworkRepository instance = HomeworkRepository._();

  final List<HomeworkItem> _homeworks = [
    const HomeworkItem(
      id: 'hw-01',
      title: 'BLoC Pattern va REST API integratsiyasi',
      course: 'Flutter Mobile Track',
      deadline: '15-Avgust, 23:59',
      description: 'Dev.to yoki Open API orqali maqolalar ro\'yxatini olib keluvchi Clean Architecture asosidagi mobil ilova yaratish.',
      status: HomeworkStatus.submitted,
      githubRepoUrl: 'https://github.com/john-student/mit-bloc-news-app',
      score: 95,
      mentorFeedback: 'Ajoyib arxitektura! Event va State ajratilishi juda to\'g\'ri bajarilgan. UI animatsiyalari ham yoqimli.',
    ),
    const HomeworkItem(
      id: 'hw-02',
      title: 'Custom Paint va Animatsiyalar',
      course: 'Flutter Mobile Track',
      deadline: '18-Avgust, 20:00',
      description: 'CustomPainter yordamida interaktiv diagramma va pulsatsiya qiluvchi yuklanish siferblatini chizish.',
      status: HomeworkStatus.pending,
    ),
    const HomeworkItem(
      id: 'hw-03',
      title: 'PostgreSQL va REST API CRUD',
      course: 'Backend Dev Track',
      deadline: '20-Avgust, 23:59',
      description: 'Node.js/Go yordamida o\'quvchilar va to\'lovlar tizimi uchun autentifikatsiyali RESTful endpoints yozish.',
      status: HomeworkStatus.pending,
    ),
  ];

  List<HomeworkItem> get homeworks => List.unmodifiable(_homeworks);

  void submitHomework(String id, String githubUrl) {
    final index = _homeworks.indexWhere((h) => h.id == id);
    if (index != -1) {
      _homeworks[index] = _homeworks[index].copyWith(
        status: HomeworkStatus.submitted,
        githubRepoUrl: githubUrl,
      );
    }
  }
}
