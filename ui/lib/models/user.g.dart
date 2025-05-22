// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
