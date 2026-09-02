// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentProfile _$StudentProfileFromJson(Map<String, dynamic> json) =>
    StudentProfile(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      courseName: json['courseName'] as String,
      group: json['group'] as String,
      mentorName: json['mentorName'] as String,
      classTime: json['classTime'] as String,
      classDays: json['classDays'] as String,
      room: json['room'] as String,
      monthlyPayment: json['monthlyPayment'] as String,
      paymentStatus: json['paymentStatus'] as String,
      attendancePercentage: (json['attendancePercentage'] as num).toInt(),
      overallScore: (json['overallScore'] as num).toInt(),
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      homeworkPercent: (json['homeworkPercent'] as num?)?.toInt() ?? 0,
      parentName: json['parentName'] as String? ?? '',
      parentPhone: json['parentPhone'] as String? ?? '',
      email: json['email'] as String? ?? 'student@mit-academy.uz',
      gender: json['gender'] as String? ?? 'male',
      avatarIndex: (json['avatarIndex'] as num?)?.toInt() ?? 0,
      bio: json['bio'] as String? ?? "Flutter & Mobile Bootcamp o'quvchisi 🚀",
    );

Map<String, dynamic> _$StudentProfileToJson(StudentProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'phone': instance.phone,
      'avatarUrl': instance.avatarUrl,
      'courseName': instance.courseName,
      'group': instance.group,
      'mentorName': instance.mentorName,
      'classTime': instance.classTime,
      'classDays': instance.classDays,
      'room': instance.room,
      'monthlyPayment': instance.monthlyPayment,
      'paymentStatus': instance.paymentStatus,
      'attendancePercentage': instance.attendancePercentage,
      'overallScore': instance.overallScore,
      'coins': instance.coins,
      'homeworkPercent': instance.homeworkPercent,
      'parentName': instance.parentName,
      'parentPhone': instance.parentPhone,
      'email': instance.email,
      'gender': instance.gender,
      'avatarIndex': instance.avatarIndex,
      'bio': instance.bio,
    };
