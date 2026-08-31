import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserRole {
  @JsonValue('student')
  student,
  @JsonValue('admin')
  admin,
  @JsonValue('teacher')
  teacher,
}

extension UserRoleExt on UserRole {
  String get label => switch (this) {
        UserRole.student => 'Talaba',
        UserRole.admin => 'Administrator',
        UserRole.teacher => 'O\'qituvchi',
      };
}

@JsonSerializable()
class UserModel {
  const UserModel({
    required this.userId,
    required this.name,
    required this.phone,
    required this.role,
    this.email,
    this.avatarUrl,
    this.groupName,
    this.token,
  });

  final String userId;
  final String name;
  final String phone;
  @JsonKey(unknownEnumValue: UserRole.student, defaultValue: UserRole.student)
  final UserRole role;
  final String? email;
  final String? avatarUrl;
  final String? groupName;
  final String? token;

  bool get isStudent => role == UserRole.student;
  bool get isAdmin => role == UserRole.admin;
  bool get isTeacher => role == UserRole.teacher;

  UserModel copyWith({
    String? userId,
    String? name,
    String? phone,
    UserRole? role,
    String? email,
    String? avatarUrl,
    String? groupName,
    String? token,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      groupName: groupName ?? this.groupName,
      token: token ?? this.token,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          phone == other.phone &&
          role == other.role;

  @override
  int get hashCode => userId.hashCode ^ phone.hashCode ^ role.hashCode;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);

    if (sanitized['person'] is Map) {
      final person = sanitized['person'] as Map;
      final fName = person['first_name']?.toString() ?? '';
      final lName = person['last_name']?.toString() ?? '';
      final fullName = '$fName $lName'.trim();

      sanitized['name'] = fullName.isNotEmpty ? fullName : (person['username']?.toString() ?? 'Talaba');
      sanitized['phone'] = person['phone_number']?.toString() ?? '';
      sanitized['userId'] = (person['id'] ?? '').toString();
      if (person['photo_url'] != null) {
        sanitized['avatarUrl'] = person['photo_url'].toString();
      }
    }

    if (sanitized['user'] is Map) {
      final user = sanitized['user'] as Map;
      if (sanitized['userId'] == null || sanitized['userId'] == '') {
        sanitized['userId'] = (user['id'] ?? '').toString();
      }
      if (sanitized['phone'] == null || sanitized['phone'] == '') {
        sanitized['phone'] = user['username']?.toString() ?? '';
      }
      if (sanitized['name'] == null || sanitized['name'] == '') {
        final fName = user['first_name']?.toString() ?? '';
        final lName = user['last_name']?.toString() ?? '';
        final fullName = '$fName $lName'.trim();
        sanitized['name'] = fullName.isNotEmpty ? fullName : (user['username']?.toString() ?? 'Talaba');
      }
      if (user['email'] != null && user['email'].toString().isNotEmpty) {
        sanitized['email'] = user['email'].toString();
      }
      if (user['role'] != null) {
        sanitized['role'] = user['role'].toString();
      }
    }

    if (sanitized['userId'] == null) {
      sanitized['userId'] = (sanitized['id'] ?? sanitized['pk'] ?? '').toString();
    }
    if (sanitized['name'] == null) {
      sanitized['name'] = sanitized['full_name']?.toString() ?? sanitized['username']?.toString() ?? 'Talaba';
    }
    if (sanitized['phone'] == null) {
      sanitized['phone'] = sanitized['phone_number']?.toString() ?? sanitized['mobile']?.toString() ?? '';
    }

    return _$UserModelFromJson(sanitized);
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
