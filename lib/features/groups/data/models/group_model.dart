import 'package:json_annotation/json_annotation.dart';
import 'package:m_it_student_platform/features/groups/domain/entities/group.dart';

part 'group_model.g.dart';

/// Data Model: Guruh ma'lumotlari modeli.
/// Faqat Data Layer ichida ishlatiladi va Entity'ga konvertatsiya qilinadi.
@JsonSerializable()
class GroupModel {
  const GroupModel({
    required this.id,
    required this.name,
    this.coursePrice,
    this.mentorName,
    this.mentorPhoto,
    this.supportTeacherName,
    this.supportTeacherPhoto,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.daysOfWeek,
    this.roomNumber,
  });

  final String id;
  final String name;
  @JsonKey(name: 'course_price')
  final String? coursePrice;
  @JsonKey(name: 'mentor_name')
  final String? mentorName;
  @JsonKey(name: 'mentor_photo')
  final String? mentorPhoto;
  @JsonKey(name: 'support_teacher_name')
  final String? supportTeacherName;
  @JsonKey(name: 'support_teacher_photo')
  final String? supportTeacherPhoto;
  @JsonKey(name: 'start_date')
  final String? startDate;
  @JsonKey(name: 'end_date')
  final String? endDate;
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;
  @JsonKey(name: 'days')
  final String? daysOfWeek;
  @JsonKey(name: 'room')
  final String? roomNumber;

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    if (sanitized['id'] != null) {
      sanitized['id'] = sanitized['id'].toString();
    }
    if (sanitized['mentor_name'] == null && sanitized['teacher_name'] != null) {
      sanitized['mentor_name'] = sanitized['teacher_name'].toString();
    }
    if (sanitized['support_teacher_name'] != null) {
      sanitized['support_teacher_name'] = sanitized['support_teacher_name'].toString();
    }
    if (sanitized['days'] == null && sanitized['schedule_label'] != null) {
      sanitized['days'] = sanitized['schedule_label'].toString();
    }
    if (sanitized['room'] != null) {
      sanitized['room'] = sanitized['room'].toString();
    }
    if (sanitized['course_price'] == null) {
      if (sanitized['monthly_fee'] != null) {
        sanitized['course_price'] = '${sanitized['monthly_fee']} so\'m';
      } else if (sanitized['course_fee'] != null) {
        sanitized['course_price'] = '${sanitized['course_fee']} so\'m';
      }
    }
    return _$GroupModelFromJson(sanitized);
  }

  Map<String, dynamic> toJson() => _$GroupModelToJson(this);

  /// Data Model ➔ Domain Entity
  Group toEntity() {
    return Group(
      id: id,
      name: name,
      coursePrice: coursePrice,
      mentorName: mentorName,
      mentorPhoto: mentorPhoto,
      supportTeacherName: supportTeacherName,
      supportTeacherPhoto: supportTeacherPhoto,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      daysOfWeek: daysOfWeek,
      roomNumber: roomNumber,
    );
  }

  /// Domain Entity ➔ Data Model
  factory GroupModel.fromEntity(Group group) {
    return GroupModel(
      id: group.id,
      name: group.name,
      coursePrice: group.coursePrice,
      mentorName: group.mentorName,
      mentorPhoto: group.mentorPhoto,
      supportTeacherName: group.supportTeacherName,
      supportTeacherPhoto: group.supportTeacherPhoto,
      startDate: group.startDate,
      endDate: group.endDate,
      isActive: group.isActive,
      daysOfWeek: group.daysOfWeek,
      roomNumber: group.roomNumber,
    );
  }
}
