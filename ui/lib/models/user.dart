import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
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

@JsonSerializable()
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
