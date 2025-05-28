import 'package:flutter_frontend/models/enums.dart'
    show FriendStatus, FriendStatusConverter;
import 'package:flutter_frontend/models/user.dart' show UserRead;
import 'package:json_annotation/json_annotation.dart';

part 'friend.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FriendRead {
  final UserRead receiver;
  final UserRead sender;

  @FriendStatusConverter()
  final FriendStatus status;

  FriendRead({
    required this.receiver,
    required this.sender,
    required this.status,
  });

  factory FriendRead.fromJson(Map<String, dynamic> json) =>
      _$FriendReadFromJson(json);
  Map<String, dynamic> toJson() => _$FriendReadToJson(this);
}
