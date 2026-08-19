import 'package:m_it_student_platform/features/lessons/domain/models/lesson_model.dart';

class MockLessonsRepository {
  static const List<StudentGroup> studentGroups = [
    StudentGroup(
      id: 'GRP-204',
      code: 'FS-204',
      name: 'Flutter Mobile Bootcamp',
      mentor: 'Abbos Qodirov',
      mentorRole: 'Senior Flutter Lead',
      schedule: 'Se - Pay - Shan (14:00 – 16:00)',
      room: '204-kompyuter xonasi',
      currentModule: 'BLoC Pattern & Clean Architecture',
      studentsCount: 12,
      isPrimary: true,
      track: LessonTrack.flutter,
    ),
    StudentGroup(
      id: 'GRP-101',
      code: 'ITF-101',
      name: 'IT Foundations & English',
      mentor: 'Nodirbek Alimov',
      mentorRole: 'IT Foundations Instructor',
      schedule: 'Juma (16:30 – 18:30)',
      room: '102-amaliyot xonasi',
      currentModule: 'Linux Terminal & Git Workflow',
      studentsCount: 15,
      isPrimary: false,
      track: LessonTrack.compLiteracy,
    ),
  ];

  static const List<Lesson> todayLessons = [
    Lesson(
      id: 'L-101',
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
      notes: 'O\'quv markaz kompyuterida Flutter SDK va VS Code o\'rnatilgan. Shaxsiy noutbuk bilan ham ishlash mumkin.',
      startsInText: '14:00 da boshlanadi',
      durationMinutes: 120,
    ),
    Lesson(
      id: 'L-102',
      subject: 'Frontend Development (React 19 & Next.js)',
      courseCode: 'FE-302',
      teacher: 'Sardor Rahimiy',
      teacherRole: 'Lead Frontend Developer',
      startTime: '16:30',
      endTime: '18:30',
      room: 'Lab-1 (Mac Studio)',
      building: 'B-bino, 1-qavat',
      status: LessonStatus.upcoming,
      date: '13-Avgust, 2026',
      dayOfWeek: 'Payshanba',
      scheduleDays: 'Se - Pay - Shan',
      track: LessonTrack.frontend,
      syllabusTopic: 'Next.js App Router, SSR va Server Actions amaliyoti',
      notes: 'Amaliy lab mashg\'uloti. GitHub repozitoriyada yangi filial ochib topshiriq topshiriladi.',
      startsInText: '16:30 da boshlanadi',
      durationMinutes: 120,
    ),
  ];

  static const List<Lesson> tomorrowLessons = [
    Lesson(
      id: 'L-103',
      subject: 'Backend Development (Node.js & PostgreSQL)',
      courseCode: 'BE-201',
      teacher: 'Javohir Mahmudov',
      teacherRole: 'Backend Architect & Mentor',
      startTime: '14:00',
      endTime: '16:00',
      room: 'Lab-2 (Dev Studio)',
      building: 'A-bino, 3-qavat',
      status: LessonStatus.upcoming,
      date: '14-Avgust, 2026',
      dayOfWeek: 'Juma',
      scheduleDays: 'Du - Chor - Juma',
      track: LessonTrack.backend,
      syllabusTopic: 'PostgreSQL Relational DB, Prisma ORM va JWT Autentifikatsiya',
      notes: 'Postman orqali API testlash va Docker konteynerida ma\'lumotlar bazasini ko\'tarish.',
      startsInText: 'Ertaga 14:00',
      durationMinutes: 120,
    ),
    Lesson(
      id: 'L-104',
      subject: 'Kompyuter Savodxonligi (IT Asoslari)',
      courseCode: 'ITF-101',
      teacher: 'Nodirbek Alimov',
      teacherRole: 'IT Foundations Instructor',
      startTime: '16:30',
      endTime: '18:30',
      room: '102-amaliyot xonasi',
      building: 'A-bino, 1-qavat',
      status: LessonStatus.upcoming,
      date: '14-Avgust, 2026',
      dayOfWeek: 'Juma',
      scheduleDays: 'Du - Chor - Juma',
      track: LessonTrack.compLiteracy,
      syllabusTopic: 'Linux Terminal buyruqlari, Git/GitHub va Tarmoq asoslari',
      notes: 'Bash skriptlar yozish va GitHub repozitoriyasiga kod push qilish amaliyoti.',
      startsInText: 'Ertaga 16:30',
      durationMinutes: 120,
    ),
  ];

  static const List<Lesson> completedLessons = [
    Lesson(
      id: 'L-100',
      subject: 'Flutter UI & Widget Architecture',
      courseCode: 'FLUT-401',
      teacher: 'Abbos Qodirov',
      teacherRole: 'Senior Flutter Lead',
      startTime: '14:00',
      endTime: '16:00',
      room: '204-kompyuter xonasi',
      building: 'A-bino, 2-qavat',
      status: LessonStatus.completed,
      date: '11-Avgust, 2026',
      dayOfWeek: 'Seshanba',
      scheduleDays: 'Se - Pay - Shan',
      track: LessonTrack.flutter,
      syllabusTopic: 'Custom Widgets va Clean Architecture',
      notes: 'M-IT platformasi dizayni to\'liq tahlil qilindi.',
      durationMinutes: 120,
    ),
  ];

  static const List<String> availableCourses = [
    'Bootcamp Foundation FN12',
    'Foundation dasturlash',
    'Flutter Mobile Bootcamp FS-204',
    'IT Foundation ITF-101',
  ];

  static final List<TopicModel> _topics = [
    const TopicModel(
      id: 'top-01',
      courseId: 'Bootcamp Foundation FN12',
      title: 'Pointerga kirish. Pointer turlari haqida',
      status: TopicStatus.notDone,
      givenDate: '02 Iyun, 14:30',
      deadline: '08:25:14',
      remainingTime: '08:25:14',
      isNewHomework: true,
      codeSnippet: 'cout << "ptr lives at: " << &ptr << endl;\ncout << "*dPtr points to: " << *dPtr << endl;\ncout << "The thing that dPtr points to has the value: " << *dPtr << endl;\ncout << "The ptr that dPtr points to, points to an int with the value: " << **dPtr << endl;\ncout << "dPtr lives at: " << &dPtr << endl;',
      description: 'Python va C++ dasturlash tili bo\'yicha xotira manzillari va ko\'rsatkichlar bilan ishlash bo\'yicha maqolamda siz qisqa mazmunda ma\'lumot berishga harakat qilaman. Hozirgi kunda biz uchun INTERNET muammo emas biz o\'zimizga kerak narsalarni internet orqali topish imkoniyati yaratilgan. Jumladan Python muhitini o\'rnatish jarayonida bevosita internet tarmog\'idan foydalanamiz. O\'rnatish jarayonini qadam va qadam ta\'riflab o\'taman. Demak o\'rnatish jarayonini boshlaymiz.',
      attachments: [
        TopicAttachment(name: 'Masalalar', size: '4.56 MB'),
        TopicAttachment(name: 'Masalalar2', size: '4.56 MB'),
      ],
    ),
    const TopicModel(
      id: 'top-02',
      courseId: 'Bootcamp Foundation FN12',
      title: 'Data structure',
      status: TopicStatus.notSubmitted,
      givenDate: '10 Noy, 2024',
      deadline: 'Tugagan',
      remainingTime: 'Tugagan',
      description: 'Massivlar, bog\'langan ro\'yxatlar (Linked Lists) va ularning xotiradagi tuzilishi bo\'yicha amaliy mashg\'ulot.',
      attachments: [
        TopicAttachment(name: 'Data_Structures_Lab', size: '3.12 MB'),
      ],
    ),
    const TopicModel(
      id: 'top-03',
      courseId: 'Bootcamp Foundation FN12',
      title: 'final :)',
      status: TopicStatus.notGiven,
      givenDate: '25 Dek, 2024',
      deadline: '-',
      remainingTime: '-',
      description: 'Kurs yakuniy loyihasi va imtihon masalalari to\'plami.',
      attachments: [],
    ),
    const TopicModel(
      id: 'top-04',
      courseId: 'Bootcamp Foundation FN12',
      title: 'Binary Tree.',
      status: TopicStatus.done,
      givenDate: '28 Okt, 2024',
      deadline: 'Tugagan',
      remainingTime: 'Tugagan',
      description: 'Binar daraxtlar, qidiruv daraxtlari (BST) va ularni aylanib chiqish (Inorder, Preorder, Postorder) algoritmlari.',
      attachments: [
        TopicAttachment(name: 'Binary_Tree_Tasks', size: '2.85 MB'),
      ],
      submittedUrl: 'https://github.com/john-student/binary-tree-cpp',
      score: 100,
    ),
    const TopicModel(
      id: 'top-05',
      courseId: 'Bootcamp Foundation FN12',
      title: 'If-Else Shart Operatorlari',
      status: TopicStatus.notDone,
      givenDate: '06 Noy, 2024',
      deadline: '07 Noy, 14:00',
      remainingTime: '07 Noy, 14:00',
      description: 'Shart operatorlari, mantiqiy ifodalar, switch-case konstruksiyalari va amaliy masalalar.',
      attachments: [
        TopicAttachment(name: 'If_Else_Masalalar', size: '1.95 MB'),
      ],
    ),
    const TopicModel(
      id: 'top-06',
      courseId: 'Bootcamp Foundation FN12',
      title: 'Data structure.',
      status: TopicStatus.done,
      givenDate: '22 Okt, 2024',
      deadline: 'Tugagan',
      remainingTime: 'Tugagan',
      description: 'Stack va Queue ma\'lumotlar tuzilmasi, FIFO va LIFO prinsiplari.',
      attachments: [
        TopicAttachment(name: 'Stack_Queue_Lab', size: '2.40 MB'),
      ],
      submittedUrl: 'https://github.com/john-student/stack-queue-cpp',
      score: 95,
    ),
  ];

  static List<TopicModel> get topics => List.unmodifiable(_topics);

  static const List<ExamModel> exams = [
    ExamModel(
      id: 'ex-01',
      title: 'Foundation Midterm Imtihoni',
      courseId: 'Bootcamp Foundation FN12',
      date: '15-Noyabr, 14:00',
      room: '204-kompyuter xonasi',
      duration: '90 daqiqa',
      status: 'Topshirilgan',
      score: 92,
      description: 'C++ asoslari, pointerlar, massivlar va funksiyalar bo\'yicha oraliq nazorat imtihoni.',
    ),
    ExamModel(
      id: 'ex-02',
      title: 'Algoritmlar & Data Structures Testi',
      courseId: 'Bootcamp Foundation FN12',
      date: '05-Dekabr, 16:00',
      room: 'Lab-1 (Mac Studio)',
      duration: '120 daqiqa',
      status: 'Topshirilgan',
      score: 96,
      description: 'Binary Tree, Graph va Dynamic Programming bo\'yicha amaliy kodlash imtihoni.',
    ),
    ExamModel(
      id: 'ex-03',
      title: 'Final Project Himoyasi',
      courseId: 'Bootcamp Foundation FN12',
      date: '28-Dekabr, 10:00',
      room: 'Katta Konferens Zal',
      duration: '180 daqiqa',
      status: 'Kutilmoqda',
      description: 'Kurs yakuniy dasturiy loyihasi taqdimoti va portfolio himoyasi.',
    ),
  ];

  static int get pendingReviewCount => _topics.where((t) => t.status == TopicStatus.notDone).length;
  static int get returnedCount => 0;
  static int get acceptedCount => _topics.where((t) => t.status == TopicStatus.done).length;

  static void submitTopicHomework(String topicId, String submittedUrl) {
    final index = _topics.indexWhere((t) => t.id == topicId);
    if (index != -1) {
      _topics[index] = _topics[index].copyWith(
        status: TopicStatus.done,
        submittedUrl: submittedUrl,
      );
    }
  }
}
