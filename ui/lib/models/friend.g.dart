// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendRead _$FriendReadFromJson(Map<String, dynamic> json) => FriendRead(
  receiver: UserRead.fromJson(json['receiver'] as Map<String, dynamic>),
  sender: UserRead.fromJson(json['sender'] as Map<String, dynamic>),
  status: const FriendStatusConverter().fromJson(json['status'] as String),
);

Map<String, dynamic> _$FriendReadToJson(FriendRead instance) =>
    <String, dynamic>{
      'receiver': instance.receiver,
      'sender': instance.sender,
      'status': const FriendStatusConverter().toJson(instance.status),
    };
