import 'package:json_annotation/json_annotation.dart';

part 'lesson_model.g.dart';

enum LessonStatus {
  @JsonValue('upcoming')
  upcoming,
  @JsonValue('active')
  active,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

enum LessonTrack {
  @JsonValue('all')
  all,
  @JsonValue('flutter')
  flutter,
  @JsonValue('frontend')
  frontend,
  @JsonValue('backend')
  backend,
  @JsonValue('compLiteracy')
  compLiteracy,
}

@JsonSerializable()
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
    this.supportTeacher,
    this.supportTeacherRole,
    this.monthlyFee,
    this.courseFee,
    this.description,
    this.studentCount,
    this.branchName,
  });

  final String id;
  @JsonKey(defaultValue: '')
  final String subject;
  @JsonKey(defaultValue: '')
  final String courseCode;
  @JsonKey(defaultValue: '')
  final String teacher;
  @JsonKey(defaultValue: '')
  final String teacherRole;
  @JsonKey(defaultValue: '')
  final String startTime;
  @JsonKey(defaultValue: '')
  final String endTime;
  @JsonKey(defaultValue: '')
  final String room;
  @JsonKey(defaultValue: '')
  final String building;
  @JsonKey(unknownEnumValue: LessonStatus.upcoming, defaultValue: LessonStatus.upcoming)
  final LessonStatus status;
  @JsonKey(defaultValue: '')
  final String date;
  @JsonKey(defaultValue: '')
  final String dayOfWeek;
  @JsonKey(defaultValue: 'Du - Chor - Juma')
  final String scheduleDays;
  @JsonKey(unknownEnumValue: LessonTrack.flutter, defaultValue: LessonTrack.flutter)
  final LessonTrack track;
  final String? syllabusTopic;
  final String? notes;
  @JsonKey(defaultValue: '')
  final String startsInText;
  @JsonKey(defaultValue: 120)
  final int durationMinutes;
  final String? supportTeacher;
  final String? supportTeacherRole;
  final String? monthlyFee;
  final String? courseFee;
  final String? description;
  final int? studentCount;
  final String? branchName;

  bool get isActive => status == LessonStatus.active;

  Lesson copyWith({
    String? id,
    String? subject,
    String? courseCode,
    String? teacher,
    String? teacherRole,
    String? startTime,
    String? endTime,
    String? room,
    String? building,
    LessonStatus? status,
    String? date,
    String? dayOfWeek,
    String? scheduleDays,
    LessonTrack? track,
    String? syllabusTopic,
    String? notes,
    String? startsInText,
    int? durationMinutes,
    String? supportTeacher,
    String? supportTeacherRole,
    String? monthlyFee,
    String? courseFee,
    String? description,
    int? studentCount,
    String? branchName,
  }) {
    return Lesson(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      courseCode: courseCode ?? this.courseCode,
      teacher: teacher ?? this.teacher,
      teacherRole: teacherRole ?? this.teacherRole,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      building: building ?? this.building,
      status: status ?? this.status,
      date: date ?? this.date,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      scheduleDays: scheduleDays ?? this.scheduleDays,
      track: track ?? this.track,
      syllabusTopic: syllabusTopic ?? this.syllabusTopic,
      notes: notes ?? this.notes,
      startsInText: startsInText ?? this.startsInText,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      supportTeacher: supportTeacher ?? this.supportTeacher,
      supportTeacherRole: supportTeacherRole ?? this.supportTeacherRole,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      courseFee: courseFee ?? this.courseFee,
      description: description ?? this.description,
      studentCount: studentCount ?? this.studentCount,
      branchName: branchName ?? this.branchName,
    );
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    if (sanitized['id'] != null) {
      sanitized['id'] = sanitized['id'].toString();
    } else {
      sanitized['id'] = '';
    }
    if (sanitized['name'] != null && sanitized['name'].toString().isNotEmpty) {
      sanitized['subject'] = sanitized['name'].toString();
    } else if (sanitized['subject'] != null && sanitized['subject'].toString().isNotEmpty) {
      sanitized['subject'] = sanitized['subject'].toString();
    } else if (sanitized['title'] != null) {
      sanitized['subject'] = sanitized['title'].toString();
    }
    sanitized['subject'] ??= '';

    if (sanitized['teacher_name'] != null && sanitized['teacher_name'].toString().isNotEmpty) {
      sanitized['teacher'] = sanitized['teacher_name'].toString();
      sanitized['teacherRole'] ??= 'Bosh ustoz';
    } else if (sanitized['teacher'] is Map) {
      final tMap = sanitized['teacher'] as Map;
      sanitized['teacher'] = tMap['name']?.toString() ?? '';
      if (tMap['role'] != null) {
        sanitized['teacherRole'] = tMap['role'].toString();
      }
    } else if (sanitized['teacher'] != null) {
      sanitized['teacher'] = sanitized['teacher'].toString();
    } else {
      sanitized['teacher'] = '';
    }
    sanitized['teacherRole'] ??= '';

    if (sanitized['supportTeacher'] == null && sanitized['support_teacher_name'] != null) {
      sanitized['supportTeacher'] = sanitized['support_teacher_name'].toString();
      sanitized['supportTeacherRole'] = 'Yordamchi ustoz';
    }

    if (sanitized['courseCode'] == null) {
      sanitized['courseCode'] = sanitized['code']?.toString() ?? sanitized['schedule']?.toString() ?? '';
    }

    sanitized['room'] = resolveRoomString(sanitized['room'] ?? sanitized['room_name'], json);

    if (sanitized['building'] == null) {
      sanitized['building'] = sanitized['branch_name']?.toString() ?? '';
    }
    sanitized['branchName'] = sanitized['branch_name']?.toString() ?? sanitized['building'];

    dynamic rawStartTime = sanitized['startTime'] ?? sanitized['start_time'] ?? sanitized['lesson_start'];
    sanitized['startTime'] = formatTimeHHmm(rawStartTime);

    dynamic rawEndTime = sanitized['endTime'] ?? sanitized['end_time'] ?? sanitized['lesson_end'];
    sanitized['endTime'] = formatTimeHHmm(rawEndTime);

    if (sanitized['syllabusTopic'] == null || sanitized['syllabusTopic'].toString().isEmpty) {
      sanitized['syllabusTopic'] = sanitized['topic']?.toString() ??
          sanitized['syllabus_topic']?.toString() ??
          sanitized['lesson_topic']?.toString();
    }

    sanitized['description'] = sanitized['description']?.toString();

    if (sanitized['date'] == null) {
      sanitized['date'] = DateTime.now().toIso8601String().substring(0, 10);
    }
    if (sanitized['dayOfWeek'] == null) {
      sanitized['dayOfWeek'] = sanitized['weekday_name']?.toString() ?? sanitized['schedule_label']?.toString() ?? '';
    }
    if (sanitized['scheduleDays'] == null || sanitized['scheduleDays'].toString().isEmpty) {
      sanitized['scheduleDays'] = sanitized['schedule_label']?.toString() ?? sanitized['schedule']?.toString() ?? '';
    }
    if (sanitized['monthlyFee'] == null && sanitized['monthly_fee'] != null) {
      final feeDigits = sanitized['monthly_fee'].toString().replaceAll(RegExp(r'[^\d]'), '');
      final feeNum = int.tryParse(feeDigits) ?? 500000;
      final formatted = feeNum.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]} ',
      );
      sanitized['monthlyFee'] = '$formatted so\'m';
    }
    if (sanitized['courseFee'] == null && sanitized['course_fee'] != null) {
      final feeDigits = sanitized['course_fee'].toString().replaceAll(RegExp(r'[^\d]'), '');
      final feeNum = int.tryParse(feeDigits) ?? 600000;
      final formatted = feeNum.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]} ',
      );
      sanitized['courseFee'] = '$formatted so\'m';
    }
    if (sanitized['studentCount'] == null && sanitized['student_count'] != null) {
      sanitized['studentCount'] = (sanitized['student_count'] as num?)?.toInt();
    }
    if (sanitized['status'] == null) {
      sanitized['status'] = sanitized['is_today'] == true ? 'active' : 'upcoming';
    }
    if (sanitized['track'] == null) {
      final nameLower = (sanitized['subject'] ?? sanitized['name'] ?? '').toString().toLowerCase();
      if (nameLower.contains('back') || nameLower.contains('python') || nameLower.contains('django')) {
        sanitized['track'] = 'backend';
      } else if (nameLower.contains('front') || nameLower.contains('react') || nameLower.contains('web')) {
        sanitized['track'] = 'frontend';
      } else {
        sanitized['track'] = 'backend';
      }
    }
    return _$LessonFromJson(sanitized);
  }

  Map<String, dynamic> toJson() => _$LessonToJson(this);
}

@JsonSerializable()
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
  @JsonKey(unknownEnumValue: LessonTrack.flutter, defaultValue: LessonTrack.flutter)
  final LessonTrack track;

  factory StudentGroup.fromJson(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    sanitized['id'] = (json['id'] ?? '').toString();
    sanitized['code'] = json['code']?.toString() ?? json['schedule']?.toString() ?? '';
    sanitized['name'] = json['name']?.toString() ?? 'Guruh';
    sanitized['mentor'] = json['teacher_name']?.toString() ?? json['mentor']?.toString() ?? '';
    sanitized['mentorRole'] = json['mentorRole']?.toString() ?? 'Mentor';
    sanitized['schedule'] = json['schedule_label']?.toString() ?? json['schedule']?.toString() ?? '';
    sanitized['room'] = resolveRoomString(json['room'] ?? json['room_name'], json);
    sanitized['currentModule'] = json['description']?.toString() ?? json['currentModule']?.toString() ?? '';
    sanitized['studentsCount'] = (json['student_count'] as num?)?.toInt() ?? (json['studentsCount'] as num?)?.toInt() ?? 1;
    sanitized['isPrimary'] = json['is_active'] == true || json['isPrimary'] == true || true;
    return _$StudentGroupFromJson(sanitized);
  }

  Map<String, dynamic> toJson() => _$StudentGroupToJson(this);
}

enum TopicStatus {
  @JsonValue('notDone')
  notDone,
  @JsonValue('done')
  done,
  @JsonValue('notSubmitted')
  notSubmitted,
  @JsonValue('notGiven')
  notGiven,
}

@JsonSerializable()
class TopicAttachment {
  const TopicAttachment({
    required this.name,
    required this.size,
    this.downloadUrl = '',
  });

  final String name;
  final String size;
  @JsonKey(defaultValue: '')
  final String downloadUrl;

  factory TopicAttachment.fromJson(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    sanitized['name'] = json['name']?.toString() ?? json['title']?.toString() ?? 'Material';
    sanitized['size'] = json['size']?.toString() ?? 'Hujjat';
    sanitized['downloadUrl'] = json['downloadUrl']?.toString() ?? json['file_url']?.toString() ?? json['url']?.toString() ?? '';
    return _$TopicAttachmentFromJson(sanitized);
  }

  Map<String, dynamic> toJson() => _$TopicAttachmentToJson(this);
}

@JsonSerializable(explicitToJson: true)
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
  @JsonKey(unknownEnumValue: TopicStatus.notDone, defaultValue: TopicStatus.notDone)
  final TopicStatus status;
  @JsonKey(defaultValue: '')
  final String givenDate;
  @JsonKey(defaultValue: '')
  final String deadline;
  @JsonKey(defaultValue: '')
  final String remainingTime;
  @JsonKey(defaultValue: false)
  final bool isNewHomework;
  final String description;
  final String? codeSnippet;
  @JsonKey(defaultValue: [])
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

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    sanitized['id'] = (json['id'] ?? '').toString();
    sanitized['courseId'] = (json['courseId'] ?? json['course_id'] ?? json['group'] ?? json['group_id'] ?? '').toString();
    sanitized['title'] = json['title']?.toString() ?? json['name']?.toString() ?? 'Dars mavzusi';
    sanitized['description'] = json['description']?.toString() ?? 'Ushbu dars bo\'yicha amaliy mashg\'ulotlar va nazariy bilimlar beriladi.';

    // Status mapping
    if (sanitized['status'] == null) {
      if (json['is_completed'] == true) {
        sanitized['status'] = 'done';
      } else if (json['is_submitted'] == true) {
        sanitized['status'] = 'done';
      } else {
        sanitized['status'] = 'notDone';
      }
    }

    // Dates
    sanitized['givenDate'] = json['givenDate']?.toString() ?? json['lesson_date']?.toString() ?? json['created_at']?.toString() ?? '';
    sanitized['deadline'] = json['deadline']?.toString() ?? '';
    sanitized['remainingTime'] = json['remainingTime']?.toString() ?? '';
    sanitized['isNewHomework'] = json['isNewHomework'] == true || json['is_new'] == true;

    // Materials / attachments
    if (sanitized['attachments'] == null && json['materials'] is List) {
      sanitized['attachments'] = (json['materials'] as List).map((m) {
        if (m is Map<String, dynamic>) {
          return {
            'name': m['name']?.toString() ?? m['title']?.toString() ?? 'Fayl',
            'size': m['size']?.toString() ?? 'PDF',
            'downloadUrl': m['file_url']?.toString() ?? m['url']?.toString() ?? m['downloadUrl']?.toString() ?? '',
          };
        }
        return {
          'name': 'Material',
          'size': 'Fayl',
          'downloadUrl': m.toString(),
        };
      }).toList();
    }

    return _$TopicModelFromJson(sanitized);
  }

  Map<String, dynamic> toJson() => _$TopicModelToJson(this);

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

@JsonSerializable()
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
  final String status;
  final int? score;
  final String description;

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    sanitized['id'] = (json['id'] ?? '').toString();
    sanitized['title'] = json['title']?.toString() ?? 'Imtihon';
    sanitized['courseId'] = (json['courseId'] ?? json['course_id'] ?? json['group'] ?? '').toString();
    sanitized['date'] = json['date']?.toString() ?? json['exam_date']?.toString() ?? '';
    sanitized['room'] = resolveRoomString(json['room'] ?? json['room_name'], json);
    sanitized['duration'] = json['duration']?.toString() ?? '90 daqiqa';
    sanitized['status'] = json['status']?.toString() ?? 'upcoming';
    sanitized['score'] = (json['score'] as num?)?.toInt();
    sanitized['description'] = json['description']?.toString() ?? 'Amaliy va nazariy imtihon sinovi.';
    return _$ExamModelFromJson(sanitized);
  }

  Map<String, dynamic> toJson() => _$ExamModelToJson(this);
}

/// Helper method to safely extract and format room information
String resolveRoomString(dynamic rawRoom, [Map<String, dynamic>? json]) {
  if (rawRoom != null) {
    if (rawRoom is String && rawRoom.trim().isNotEmpty) {
      final trimmed = rawRoom.trim();
      if (RegExp(r'^\d+$').hasMatch(trimmed)) return 'Xona $trimmed';
      return trimmed;
    }
    if (rawRoom is num) return 'Xona $rawRoom';
    if (rawRoom is Map) {
      final name = rawRoom['name'] ??
          rawRoom['title'] ??
          rawRoom['room_name'] ??
          rawRoom['room_number'] ??
          rawRoom['room'] ??
          rawRoom['number'] ??
          rawRoom['classroom'];
      if (name != null && name.toString().trim().isNotEmpty) {
        final nameStr = name.toString().trim();
        return RegExp(r'^\d+$').hasMatch(nameStr) ? 'Xona $nameStr' : nameStr;
      }
    }
  }
  if (json != null) {
    final fallback = json['room'] ??
        json['room_name'] ??
        json['room_number'] ??
        json['classroom'] ??
        json['classroom_name'] ??
        json['auditorium'] ??
        json['auditory'] ??
        json['cabinet'] ??
        json['xona'] ??
        json['xona_nomi'] ??
        json['xona_raqami'];
    if (fallback != null && fallback != rawRoom) {
      return resolveRoomString(fallback);
    }
  }
  return '';
}

/// Helper method to safely format time as HH:mm
String formatTimeHHmm(dynamic raw) {
  if (raw == null) return '';
  final str = raw.toString().trim();
  if (str.isEmpty) return '';
  final match = RegExp(r'^(\d{1,2}:\d{2})(:\d{2})?').firstMatch(str);
  if (match != null) {
    return match.group(1)!;
  }
  return str;
}
