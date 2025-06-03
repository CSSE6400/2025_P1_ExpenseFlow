import 'package:flutter_frontend/models/enums.dart';
import 'package:flutter_frontend/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'group.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class GroupRead {
  final String groupId;
  final String name;
  final String description;

  GroupRead({
    required this.groupId,
    required this.name,
    required this.description,
  });

  factory GroupRead.fromJson(Map<String, dynamic> json) =>
      _$GroupReadFromJson(json);
  Map<String, dynamic> toJson() => _$GroupReadToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GroupReadWithMembers {
  final String groupId;
  final String name;
  final String description;

  final List<UserReadMinimal> members;

  GroupReadWithMembers({
    required this.groupId,
    required this.name,
    required this.description,
    required this.members,
  });

  factory GroupReadWithMembers.fromJson(Map<String, dynamic> json) =>
      _$GroupReadWithMembersFromJson(json);
  Map<String, dynamic> toJson() => _$GroupReadWithMembersToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GroupCreate {
  final String name;
  final String description;

  GroupCreate({required this.name, required this.description});

  factory GroupCreate.fromJson(Map<String, dynamic> json) =>
      _$GroupCreateFromJson(json);
  Map<String, dynamic> toJson() => _$GroupCreateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GroupUpdate {
  final String name;
  final String description;

  GroupUpdate({required this.name, required this.description});

  factory GroupUpdate.fromJson(Map<String, dynamic> json) =>
      _$GroupUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$GroupUpdateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GroupUserRead {
  final String groupId;
  final String name;
  final String description;
  final DateTime joinedAt;

  @GroupRoleConverter()
  final GroupRole role;

  GroupUserRead({
    required this.groupId,
    required this.name,
    required this.description,
    required this.role,
    required this.joinedAt,
  });

  factory GroupUserRead.fromJson(Map<String, dynamic> json) =>
      _$GroupUserReadFromJson(json);
  Map<String, dynamic> toJson() => _$GroupUserReadToJson(this);
}
