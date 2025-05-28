// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupRead _$GroupReadFromJson(Map<String, dynamic> json) => GroupRead(
  groupId: json['group_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$GroupReadToJson(GroupRead instance) => <String, dynamic>{
  'group_id': instance.groupId,
  'name': instance.name,
  'description': instance.description,
};

GroupCreate _$GroupCreateFromJson(Map<String, dynamic> json) => GroupCreate(
  name: json['name'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$GroupCreateToJson(GroupCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
    };

GroupUpdate _$GroupUpdateFromJson(Map<String, dynamic> json) => GroupUpdate(
  name: json['name'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$GroupUpdateToJson(GroupUpdate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
    };

GroupUserRead _$GroupUserReadFromJson(Map<String, dynamic> json) =>
    GroupUserRead(
      groupId: json['group_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      role: const GroupRoleConverter().fromJson(json['role'] as String),
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );

Map<String, dynamic> _$GroupUserReadToJson(GroupUserRead instance) =>
    <String, dynamic>{
      'group_id': instance.groupId,
      'name': instance.name,
      'description': instance.description,
      'joined_at': instance.joinedAt.toIso8601String(),
      'role': const GroupRoleConverter().toJson(instance.role),
    };
