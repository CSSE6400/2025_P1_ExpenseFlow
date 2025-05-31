// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserReadMinimal _$UserReadMinimalFromJson(Map<String, dynamic> json) =>
    UserReadMinimal(
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
    );

Map<String, dynamic> _$UserReadMinimalToJson(UserReadMinimal instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'nickname': instance.nickname,
    };

UserRead _$UserReadFromJson(Map<String, dynamic> json) => UserRead(
  userId: json['user_id'] as String,
  nickname: json['nickname'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
);

Map<String, dynamic> _$UserReadToJson(UserRead instance) => <String, dynamic>{
  'user_id': instance.userId,
  'nickname': instance.nickname,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
};

UserCreate _$UserCreateFromJson(Map<String, dynamic> json) => UserCreate(
  nickname: json['nickname'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
);

Map<String, dynamic> _$UserCreateToJson(UserCreate instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
    };

UserGroupRead _$UserGroupReadFromJson(Map<String, dynamic> json) =>
    UserGroupRead(
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      role: const GroupRoleConverter().fromJson(json['role'] as String),
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );

Map<String, dynamic> _$UserGroupReadToJson(UserGroupRead instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'nickname': instance.nickname,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'joined_at': instance.joinedAt.toIso8601String(),
      'role': const GroupRoleConverter().toJson(instance.role),
    };
