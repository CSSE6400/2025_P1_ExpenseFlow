import 'package:flutter_frontend/models/enums.dart'
    show GroupRole, GroupRoleConverter;
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserReadMinimal {
  final String userId;
  final String nickname;

  UserReadMinimal({required this.userId, required this.nickname});

  factory UserReadMinimal.fromJson(Map<String, dynamic> json) =>
      _$UserReadMinimalFromJson(json);
  Map<String, dynamic> toJson() => _$UserReadMinimalToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserRead {
  final String userId;
  final String nickname;
  final String firstName;
  final String lastName;

  UserRead({
    required this.userId,
    required this.nickname,
    required this.firstName,
    required this.lastName,
  });

  factory UserRead.fromJson(Map<String, dynamic> json) =>
      _$UserReadFromJson(json);
  Map<String, dynamic> toJson() => _$UserReadToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserCreate {
  final String nickname;
  final String firstName;
  final String lastName;

  UserCreate({
    required this.nickname,
    required this.firstName,
    required this.lastName,
  });

  factory UserCreate.fromJson(Map<String, dynamic> json) =>
      _$UserCreateFromJson(json);
  Map<String, dynamic> toJson() => _$UserCreateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserGroupRead {
  final String userId;
  final String nickname;
  final String firstName;
  final String lastName;

  final DateTime joinedAt;

  @GroupRoleConverter()
  final GroupRole role;

  UserGroupRead({
    required this.userId,
    required this.nickname,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.joinedAt,
  });

  factory UserGroupRead.fromJson(Map<String, dynamic> json) =>
      _$UserGroupReadFromJson(json);
  Map<String, dynamic> toJson() => _$UserGroupReadToJson(this);
}
