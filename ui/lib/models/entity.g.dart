// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntityRead _$EntityReadFromJson(Map<String, dynamic> json) => EntityRead(
  entityId: json['entity_id'] as String,
  kind: const EntityKindConverter().fromJson(json['kind'] as String),
);

Map<String, dynamic> _$EntityReadToJson(EntityRead instance) =>
    <String, dynamic>{
      'entity_id': instance.entityId,
      'kind': const EntityKindConverter().toJson(instance.kind),
    };
