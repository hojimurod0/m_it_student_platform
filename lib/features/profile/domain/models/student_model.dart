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
    this.parentPhone = '+998 (99) 876-54-32',
    this.email = 'john.smith@mit-academy.uz',
    this.gender = 'male', // 'male' (Erkak/O'g'il bola) | 'female' (Ayol/Qiz bola)
    this.avatarIndex = 0,
    this.bio = 'Flutter Mobile Bootcamp o\'quvchisi 🚀',
  });

  final String id;
  final String fullName;
  final String phone;
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
  final String parentPhone;
  final String email;
  final String gender;
  final int avatarIndex;
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

  bool get isFemale => avatarIndex >= 2 || gender == 'female';
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
    String? fullName,
    String? phone,
    String? parentPhone,
    String? email,
    String? gender,
    int? avatarIndex,
    String? bio,
    String? avatarUrl,
  }) {
    return StudentProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      courseName: courseName,
      group: group,
      mentorName: mentorName,
      classTime: classTime,
      classDays: classDays,
      room: room,
      monthlyPayment: monthlyPayment,
      paymentStatus: paymentStatus,
      attendancePercentage: attendancePercentage,
      overallScore: overallScore,
      parentPhone: parentPhone ?? this.parentPhone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      bio: bio ?? this.bio,
    );
  }
}
