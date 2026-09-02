import 'package:json_annotation/json_annotation.dart';

part 'student_model.g.dart';

@JsonSerializable()
class StudentProfile {
  const StudentProfile({
    required this.id,
    required this.fullName,
    required this.phone,
    this.avatarUrl = '',
    required this.courseName,
    required this.group,
    required this.mentorName,
    required this.classTime,
    required this.classDays,
    required this.room,
    required this.monthlyPayment,
    required this.paymentStatus,
    required this.attendancePercentage,
    required this.overallScore,
    this.coins = 0,
    this.homeworkPercent = 0,
    this.parentName = '',
    this.parentPhone = '',
    this.email = 'student@mit-academy.uz',
    this.gender = 'male',
    this.avatarIndex = 0,
    this.bio = 'Flutter & Mobile Bootcamp o\'quvchisi 🚀',
  });

  final String id;
  final String fullName;
  final String phone;
  @JsonKey(defaultValue: '')
  final String avatarUrl;
  final String courseName;
  final String group;
  final String mentorName;
  final String classTime;
  final String classDays;
  final String room;
  final String monthlyPayment;
  final String paymentStatus;
  final int attendancePercentage;
  final int overallScore;
  /// Shartnoma tangalari (progress API dan)
  @JsonKey(defaultValue: 0)
  final int coins;
  /// Vazifa topshirish foizi (progress API dan)
  @JsonKey(defaultValue: 0)
  final int homeworkPercent;
  @JsonKey(defaultValue: '')
  final String parentName;
  @JsonKey(defaultValue: '')
  final String parentPhone;
  @JsonKey(defaultValue: 'student@mit-academy.uz')
  final String email;
  @JsonKey(defaultValue: 'male')
  final String gender;
  @JsonKey(defaultValue: 0)
  final int avatarIndex;
  @JsonKey(defaultValue: "Flutter & Mobile Bootcamp o'quvchisi 🚀")
  final String bio;

  static const List<String> availableAvatars = [
    '👦🏻',
    '👨‍💻',
    '🧕',
    '👩‍💻',
  ];

  static const List<String> maleAvatars = ['👦🏻', '👨‍💻'];
  static const List<String> femaleAvatars = ['🧕', '👩‍💻'];

  String get resolvedAvatarEmoji {
    if (avatarIndex >= 0 && avatarIndex < availableAvatars.length) {
      return availableAvatars[avatarIndex];
    }
    return availableAvatars.first;
  }

  bool get isFemale =>
      avatarIndex == 1 ||
      avatarIndex >= 2 ||
      gender.toLowerCase() == 'female' ||
      gender.toLowerCase() == 'ayol';
  bool get isMale => !isFemale;

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty && parts.first.isNotEmpty ? parts.first : fullName;
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'ST';
  }

  StudentProfile copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? parentName,
    String? parentPhone,
    String? email,
    String? gender,
    int? avatarIndex,
    String? bio,
    String? avatarUrl,
    String? courseName,
    String? group,
    String? mentorName,
    String? classTime,
    String? classDays,
    String? room,
    String? monthlyPayment,
    String? paymentStatus,
    int? attendancePercentage,
    int? overallScore,
    int? coins,
    int? homeworkPercent,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      courseName: courseName ?? this.courseName,
      group: group ?? this.group,
      mentorName: mentorName ?? this.mentorName,
      classTime: classTime ?? this.classTime,
      classDays: classDays ?? this.classDays,
      room: room ?? this.room,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      overallScore: overallScore ?? this.overallScore,
      coins: coins ?? this.coins,
      homeworkPercent: homeworkPercent ?? this.homeworkPercent,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      bio: bio ?? this.bio,
    );
  }

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    sanitized['id'] = (json['id'] ?? json['userId'] ?? 'ST-10245').toString();
    if (sanitized['fullName'] == null) {
      if (json['first_name'] != null || json['last_name'] != null) {
        final fn = json['first_name']?.toString() ?? '';
        final ln = json['last_name']?.toString() ?? '';
        sanitized['fullName'] = '$fn $ln'.trim();
      } else {
        sanitized['fullName'] = json['name']?.toString() ?? json['full_name']?.toString() ?? 'Hojimurod Obidjanov';
      }
    }
    sanitized['phone'] = json['phone']?.toString() ?? json['phone_number']?.toString() ?? '+998 94 009 03 56';
    sanitized['avatarUrl'] = json['avatarUrl']?.toString() ?? json['photo_url']?.toString() ?? '';
    sanitized['courseName'] = json['courseName']?.toString() ?? json['course_name']?.toString() ?? json['group_name']?.toString() ?? 'Back end 05';
    sanitized['group'] = json['group']?.toString() ?? json['group_name']?.toString() ?? 'Back end 05';
    sanitized['mentorName'] = json['mentorName']?.toString() ?? json['mentor_name']?.toString() ?? json['teacher_name']?.toString() ?? 'Shohjaxon Jo\'rayev';
    sanitized['classTime'] = json['classTime']?.toString() ?? '11:00 – 14:00';
    sanitized['classDays'] = json['classDays']?.toString() ?? json['schedule_label']?.toString() ?? 'Du - Chor - Juma';
    sanitized['room'] = json['room']?.toString() ?? json['room_name']?.toString() ?? 'Google xonasi';
    if (sanitized['monthlyPayment'] == null) {
      if (json['monthly_fee'] != null) {
        sanitized['monthlyPayment'] = "${json['monthly_fee']} so'm";
      } else if (json['monthly_rate'] != null) {
        sanitized['monthlyPayment'] = "${json['monthly_rate']} so'm";
      } else if (json['price'] != null) {
        sanitized['monthlyPayment'] = "${json['price']} so'm";
      } else {
        sanitized['monthlyPayment'] = "500 000 so'm";
      }
    }
    sanitized['paymentStatus'] = json['paymentStatus']?.toString() ?? json['payment_status']?.toString() ?? 'To\'langan';
    sanitized['attendancePercentage'] = (json['attendancePercentage'] as num?)?.toInt() ??
        (json['attendance_percentage'] as num?)?.toInt() ??
        (json['attendance_rate'] as num?)?.toInt() ??
        (json['attendance'] as num?)?.toInt() ??
        (json['davomat'] as num?)?.toInt() ??
        0;
    sanitized['overallScore'] = (json['overallScore'] as num?)?.toInt() ??
        (json['overall_score'] as num?)?.toInt() ??
        (json['gpa'] as num?)?.toInt() ??
        (json['average_score'] as num?)?.toInt() ??
        (json['score'] as num?)?.toInt() ??
        (json['progress'] as num?)?.toInt() ??
        (json['rating'] as num?)?.toInt() ??
        (json['ozlashtirish'] as num?)?.toInt() ??
        0;

    // Backend parent name & phone parsing
    final rawParentPhone = json['parent_phone'] ??
        json['parent_phone_number'] ??
        json['parents_phone'] ??
        json['father_phone'] ??
        json['mother_phone'] ??
        json['parentPhone'];
    sanitized['parentPhone'] = (rawParentPhone != null && rawParentPhone.toString() != 'null')
        ? rawParentPhone.toString().trim()
        : '';

    final rawParentName = json['parent_name'] ??
        json['parents_name'] ??
        json['father_name'] ??
        json['mother_name'] ??
        json['parentName'];
    sanitized['parentName'] = (rawParentName != null && rawParentName.toString() != 'null')
        ? rawParentName.toString().trim()
        : '';

    sanitized['email'] = json['email']?.toString() ?? 'student@mit-academy.uz';
    sanitized['gender'] = json['gender']?.toString() ?? 'male';
    sanitized['avatarIndex'] = (json['avatarIndex'] as num?)?.toInt() ?? 0;
    sanitized['bio'] = json['bio']?.toString() ?? 'M-IT Academy talabasi 🚀';
    sanitized['coins'] = (json['coins'] as num?)?.toInt() ??
        (json['total_coins'] as num?)?.toInt() ??
        (json['coin'] as num?)?.toInt() ??
        0;
    sanitized['homeworkPercent'] = (json['homeworkPercent'] as num?)?.toInt() ??
        (json['homework_percent'] as num?)?.toInt() ??
        (json['homework_submission_rate'] as num?)?.toInt() ??
        0;
    return _$StudentProfileFromJson(sanitized);
  }

  Map<String, dynamic> toJson() => _$StudentProfileToJson(this);
}
