enum LessonStatus {
  upcoming,
  active,
  completed,
  cancelled,
}

enum LessonTrack {
  all,
  flutter,
  frontend,
  backend,
  compLiteracy,
}

class Lesson {
  const Lesson({
    required this.id,
    required this.subject,
    required this.courseCode,
    required this.teacher,
    required this.teacherRole,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.building,
    required this.status,
    required this.date,
    required this.dayOfWeek,
    this.scheduleDays = 'Du - Chor - Juma',
    this.track = LessonTrack.flutter,
    this.syllabusTopic,
    this.notes,
    this.startsInText = '',
    this.durationMinutes = 120,
  });

  final String id;
  final String subject;
  final String courseCode;
  final String teacher;
  final String teacherRole;
  final String startTime;
  final String endTime;
  final String room;
  final String building;
  final LessonStatus status;
  final String date;
  final String dayOfWeek;
  final String scheduleDays;
  final LessonTrack track;
  final String? syllabusTopic;
  final String? notes;
  final String startsInText;
  final int durationMinutes;

  bool get isActive => status == LessonStatus.active;
}

class StudentGroup {
  const StudentGroup({
    required this.id,
    required this.code,
    required this.name,
    required this.mentor,
    required this.mentorRole,
    required this.schedule,
    required this.room,
    required this.currentModule,
    required this.studentsCount,
    required this.isPrimary,
    required this.track,
  });

  final String id;
  final String code;
  final String name;
  final String mentor;
  final String mentorRole;
  final String schedule;
  final String room;
  final String currentModule;
  final int studentsCount;
  final bool isPrimary;
  final LessonTrack track;
}

enum TopicStatus {
  notDone, // Bajarilmagan (peach/red)
  done, // Bajarilgan (green)
  notSubmitted, // Topshirilmagan (purple)
  notGiven, // Berilmagan (gray)
}

class TopicAttachment {
  const TopicAttachment({
    required this.name,
    required this.size,
    this.downloadUrl = '',
  });

  final String name;
  final String size;
  final String downloadUrl;
}

class TopicModel {
  const TopicModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.status,
    this.givenDate = '',
    this.deadline = '',
    this.remainingTime = '',
    this.isNewHomework = false,
    required this.description,
    this.codeSnippet,
    this.attachments = const [],
    this.submittedUrl,
    this.score,
  });

  final String id;
  final String courseId;
  final String title;
  final TopicStatus status;
  final String givenDate;
  final String deadline;
  final String remainingTime;
  final bool isNewHomework;
  final String description;
  final String? codeSnippet;
  final List<TopicAttachment> attachments;
  final String? submittedUrl;
  final int? score;

  String get statusLabel {
    switch (status) {
      case TopicStatus.notDone:
        return 'Bajarilmagan';
      case TopicStatus.done:
        return 'Bajarilgan';
      case TopicStatus.notSubmitted:
        return 'Topshirilmagan';
      case TopicStatus.notGiven:
        return 'Berilmagan';
    }
  }

  TopicModel copyWith({
    String? id,
    String? courseId,
    String? title,
    TopicStatus? status,
    String? givenDate,
    String? deadline,
    String? remainingTime,
    bool? isNewHomework,
    String? description,
    String? codeSnippet,
    List<TopicAttachment>? attachments,
    String? submittedUrl,
    int? score,
  }) {
    return TopicModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      status: status ?? this.status,
      givenDate: givenDate ?? this.givenDate,
      deadline: deadline ?? this.deadline,
      remainingTime: remainingTime ?? this.remainingTime,
      isNewHomework: isNewHomework ?? this.isNewHomework,
      description: description ?? this.description,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      attachments: attachments ?? this.attachments,
      submittedUrl: submittedUrl ?? this.submittedUrl,
      score: score ?? this.score,
    );
  }
}

class ExamModel {
  const ExamModel({
    required this.id,
    required this.title,
    required this.courseId,
    required this.date,
    required this.room,
    required this.duration,
    required this.status,
    this.score,
    required this.description,
  });

  final String id;
  final String title;
  final String courseId;
  final String date;
  final String room;
  final String duration;
  final String status; // 'Topshirilgan' | 'Kutilmoqda'
  final int? score;
  final String description;
}
