// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lesson _$LessonFromJson(Map<String, dynamic> json) => Lesson(
  id: json['id'] as String,
  subject: json['subject'] as String? ?? '',
  courseCode: json['courseCode'] as String? ?? '',
  teacher: json['teacher'] as String? ?? '',
  teacherRole: json['teacherRole'] as String? ?? '',
  startTime: json['startTime'] as String? ?? '',
  endTime: json['endTime'] as String? ?? '',
  room: json['room'] as String? ?? '',
  building: json['building'] as String? ?? '',
  status:
      $enumDecodeNullable(
        _$LessonStatusEnumMap,
        json['status'],
        unknownValue: LessonStatus.upcoming,
      ) ??
      LessonStatus.upcoming,
  date: json['date'] as String? ?? '',
  dayOfWeek: json['dayOfWeek'] as String? ?? '',
  scheduleDays: json['scheduleDays'] as String? ?? 'Du - Chor - Juma',
  track:
      $enumDecodeNullable(
        _$LessonTrackEnumMap,
        json['track'],
        unknownValue: LessonTrack.flutter,
      ) ??
      LessonTrack.flutter,
  syllabusTopic: json['syllabusTopic'] as String?,
  notes: json['notes'] as String?,
  startsInText: json['startsInText'] as String? ?? '',
  durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 120,
  supportTeacher: json['supportTeacher'] as String?,
  supportTeacherRole: json['supportTeacherRole'] as String?,
  monthlyFee: json['monthlyFee'] as String?,
  courseFee: json['courseFee'] as String?,
  description: json['description'] as String?,
  studentCount: (json['studentCount'] as num?)?.toInt(),
  branchName: json['branchName'] as String?,
);

Map<String, dynamic> _$LessonToJson(Lesson instance) => <String, dynamic>{
  'id': instance.id,
  'subject': instance.subject,
  'courseCode': instance.courseCode,
  'teacher': instance.teacher,
  'teacherRole': instance.teacherRole,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'room': instance.room,
  'building': instance.building,
  'status': _$LessonStatusEnumMap[instance.status]!,
  'date': instance.date,
  'dayOfWeek': instance.dayOfWeek,
  'scheduleDays': instance.scheduleDays,
  'track': _$LessonTrackEnumMap[instance.track]!,
  'syllabusTopic': instance.syllabusTopic,
  'notes': instance.notes,
  'startsInText': instance.startsInText,
  'durationMinutes': instance.durationMinutes,
  'supportTeacher': instance.supportTeacher,
  'supportTeacherRole': instance.supportTeacherRole,
  'monthlyFee': instance.monthlyFee,
  'courseFee': instance.courseFee,
  'description': instance.description,
  'studentCount': instance.studentCount,
  'branchName': instance.branchName,
};

const _$LessonStatusEnumMap = {
  LessonStatus.upcoming: 'upcoming',
  LessonStatus.active: 'active',
  LessonStatus.completed: 'completed',
  LessonStatus.cancelled: 'cancelled',
};

const _$LessonTrackEnumMap = {
  LessonTrack.all: 'all',
  LessonTrack.flutter: 'flutter',
  LessonTrack.frontend: 'frontend',
  LessonTrack.backend: 'backend',
  LessonTrack.compLiteracy: 'compLiteracy',
};

StudentGroup _$StudentGroupFromJson(Map<String, dynamic> json) => StudentGroup(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  mentor: json['mentor'] as String,
  mentorRole: json['mentorRole'] as String,
  schedule: json['schedule'] as String,
  room: json['room'] as String,
  currentModule: json['currentModule'] as String,
  studentsCount: (json['studentsCount'] as num).toInt(),
  isPrimary: json['isPrimary'] as bool,
  track:
      $enumDecodeNullable(
        _$LessonTrackEnumMap,
        json['track'],
        unknownValue: LessonTrack.flutter,
      ) ??
      LessonTrack.flutter,
);

Map<String, dynamic> _$StudentGroupToJson(StudentGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'mentor': instance.mentor,
      'mentorRole': instance.mentorRole,
      'schedule': instance.schedule,
      'room': instance.room,
      'currentModule': instance.currentModule,
      'studentsCount': instance.studentsCount,
      'isPrimary': instance.isPrimary,
      'track': _$LessonTrackEnumMap[instance.track]!,
    };

TopicAttachment _$TopicAttachmentFromJson(Map<String, dynamic> json) =>
    TopicAttachment(
      name: json['name'] as String,
      size: json['size'] as String,
      downloadUrl: json['downloadUrl'] as String? ?? '',
    );

Map<String, dynamic> _$TopicAttachmentToJson(TopicAttachment instance) =>
    <String, dynamic>{
      'name': instance.name,
      'size': instance.size,
      'downloadUrl': instance.downloadUrl,
    };

TopicModel _$TopicModelFromJson(Map<String, dynamic> json) => TopicModel(
  id: json['id'] as String,
  courseId: json['courseId'] as String,
  title: json['title'] as String,
  status:
      $enumDecodeNullable(
        _$TopicStatusEnumMap,
        json['status'],
        unknownValue: TopicStatus.notDone,
      ) ??
      TopicStatus.notDone,
  givenDate: json['givenDate'] as String? ?? '',
  deadline: json['deadline'] as String? ?? '',
  remainingTime: json['remainingTime'] as String? ?? '',
  isNewHomework: json['isNewHomework'] as bool? ?? false,
  description: json['description'] as String,
  codeSnippet: json['codeSnippet'] as String?,
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => TopicAttachment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  submittedUrl: json['submittedUrl'] as String?,
  score: (json['score'] as num?)?.toInt(),
);

Map<String, dynamic> _$TopicModelToJson(TopicModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'courseId': instance.courseId,
      'title': instance.title,
      'status': _$TopicStatusEnumMap[instance.status]!,
      'givenDate': instance.givenDate,
      'deadline': instance.deadline,
      'remainingTime': instance.remainingTime,
      'isNewHomework': instance.isNewHomework,
      'description': instance.description,
      'codeSnippet': instance.codeSnippet,
      'attachments': instance.attachments.map((e) => e.toJson()).toList(),
      'submittedUrl': instance.submittedUrl,
      'score': instance.score,
    };

const _$TopicStatusEnumMap = {
  TopicStatus.notDone: 'notDone',
  TopicStatus.done: 'done',
  TopicStatus.notSubmitted: 'notSubmitted',
  TopicStatus.notGiven: 'notGiven',
};

ExamModel _$ExamModelFromJson(Map<String, dynamic> json) => ExamModel(
  id: json['id'] as String,
  title: json['title'] as String,
  courseId: json['courseId'] as String,
  date: json['date'] as String,
  room: json['room'] as String,
  duration: json['duration'] as String,
  status: json['status'] as String,
  score: (json['score'] as num?)?.toInt(),
  description: json['description'] as String,
);

Map<String, dynamic> _$ExamModelToJson(ExamModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'courseId': instance.courseId,
  'date': instance.date,
  'room': instance.room,
  'duration': instance.duration,
  'status': instance.status,
  'score': instance.score,
  'description': instance.description,
};
