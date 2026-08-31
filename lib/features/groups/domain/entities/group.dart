/// Pure Domain Entity: Guruh ob'ekti.
/// Bu qatlamda hech qanday json_serializable yoki tashqi frameworkga tobelik yo'q.
class Group {
  final String id;
  final String name;
  final String? coursePrice;
  final String? mentorName;
  final String? mentorPhoto;
  final String? supportTeacherName;
  final String? supportTeacherPhoto;
  final String? startDate;
  final String? endDate;
  final bool isActive;
  final String? daysOfWeek;
  final String? roomNumber;

  const Group({
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

  Group copyWith({
    String? id,
    String? name,
    String? coursePrice,
    String? mentorName,
    String? mentorPhoto,
    String? supportTeacherName,
    String? supportTeacherPhoto,
    String? startDate,
    String? endDate,
    bool? isActive,
    String? daysOfWeek,
    String? roomNumber,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      coursePrice: coursePrice ?? this.coursePrice,
      mentorName: mentorName ?? this.mentorName,
      mentorPhoto: mentorPhoto ?? this.mentorPhoto,
      supportTeacherName: supportTeacherName ?? this.supportTeacherName,
      supportTeacherPhoto: supportTeacherPhoto ?? this.supportTeacherPhoto,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      roomNumber: roomNumber ?? this.roomNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Group && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
