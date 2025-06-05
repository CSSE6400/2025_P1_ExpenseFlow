import 'package:flutter_frontend/models/enums.dart';

import 'package:json_annotation/json_annotation.dart';

part 'entity.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class EntityRead {
  final String entityId;

  @EntityKindConverter()
  final EntityKind kind;

  EntityRead({required this.entityId, required this.kind});

  factory EntityRead.fromJson(Map<String, dynamic> json) =>
      _$EntityReadFromJson(json);
  Map<String, dynamic> toJson() => _$EntityReadToJson(this);
}
