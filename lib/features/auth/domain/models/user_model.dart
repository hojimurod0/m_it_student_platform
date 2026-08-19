enum UserRole {
  student,
  admin,
}

extension UserRoleExt on UserRole {
  String get label => switch (this) {
        UserRole.student => 'Talaba',
        UserRole.admin => 'Administrator',
      };
}

class UserModel {
  const UserModel({
    required this.userId,
    required this.name,
    required this.phone,
    required this.role,
    this.email,
    this.avatarUrl,
    this.groupName,
  });

  final String userId;
  final String name;
  final String phone;
  final UserRole role;
  final String? email;
  final String? avatarUrl;
  final String? groupName;

  bool get isStudent => role == UserRole.student;
  bool get isAdmin => role == UserRole.admin;

  UserModel copyWith({
    String? userId,
    String? name,
    String? phone,
    UserRole? role,
    String? email,
    String? avatarUrl,
    String? groupName,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      groupName: groupName ?? this.groupName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'role': role.name,
      'email': email,
      'avatarUrl': avatarUrl,
      'groupName': groupName,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.student,
      ),
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      groupName: json['groupName'] as String?,
    );
  }
}
