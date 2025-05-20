// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRead _$UserReadFromJson(Map<String, dynamic> json) => UserRead(
  userId: json['userId'] as String,
  nickname: json['nickname'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
);

Map<String, dynamic> _$UserReadToJson(UserRead instance) => <String, dynamic>{
  'userId': instance.userId,
  'nickname': instance.nickname,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
};

UserCreate _$UserCreateFromJson(Map<String, dynamic> json) => UserCreate(
  nickname: json['nickname'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
);

Map<String, dynamic> _$UserCreateToJson(UserCreate instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
    };
