enum AttendanceType {
  faceId,
  manual,
  qr,
}

/// Pure Domain Entity: Davomat yozuvi
class AttendanceRecord {
  final String id;
  final String date;
  final String? checkin;
  final String? checkout;
  final AttendanceType type;
  final String? groupName;
  final String? note;

  const AttendanceRecord({
    required this.id,
    required this.date,
    this.checkin,
    this.checkout,
    this.type = AttendanceType.faceId,
    this.groupName,
    this.note,
  });

  bool get hasCheckin => checkin != null && checkin!.isNotEmpty;
  bool get hasCheckout => checkout != null && checkout!.isNotEmpty;
  bool get isPresent => hasCheckin;

  AttendanceRecord copyWith({
    String? id,
    String? date,
    String? checkin,
    String? checkout,
    AttendanceType? type,
    String? groupName,
    String? note,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      checkin: checkin ?? this.checkin,
      checkout: checkout ?? this.checkout,
      type: type ?? this.type,
      groupName: groupName ?? this.groupName,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceRecord && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
