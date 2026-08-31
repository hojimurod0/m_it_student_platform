// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  userId: json['userId'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  role:
      $enumDecodeNullable(
        _$UserRoleEnumMap,
        json['role'],
        unknownValue: UserRole.student,
      ) ??
      UserRole.student,
  email: json['email'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  groupName: json['groupName'] as String?,
  token: json['token'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'userId': instance.userId,
  'name': instance.name,
  'phone': instance.phone,
  'role': _$UserRoleEnumMap[instance.role]!,
  'email': instance.email,
  'avatarUrl': instance.avatarUrl,
  'groupName': instance.groupName,
  'token': instance.token,
};

const _$UserRoleEnumMap = {
  UserRole.student: 'student',
  UserRole.admin: 'admin',
  UserRole.teacher: 'teacher',
};
