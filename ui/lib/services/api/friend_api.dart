import 'dart:convert';

import 'package:flutter_frontend/models/friend.dart' show FriendRead;
import 'package:flutter_frontend/models/user.dart' show UserRead;
import 'package:flutter_frontend/services/api/common.dart';
import 'package:flutter_frontend/services/api_service.dart' show ApiException;

class FriendApiClient extends BaseApiClient {
  FriendApiClient(super.client, super.baseUrl, super.logger);

  Future<List<UserRead>> getFriends() async {
    final response = await client.get(backendUri("/friends"));

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => UserRead.fromJson(e))
          .toList();
    } else {
      logger.info(
        "Failed to fetch friends: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        'Failed to fetch friends',
        response.body,
      );
    }
  }

  Future<List<UserRead>> getRequests(bool sent) async {
    // 'sent' is to toggle between getting 'sent' friend requests and 'received' friend requests
    final response = await client.get(
      backendUri("/friends/requests?sent=$sent"),
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => UserRead.fromJson(e))
          .toList();
    } else {
      logger.info(
        "Failed to fetch friends: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        'Failed to fetch friends',
        response.body,
      );
    }
  }

  Future<FriendRead?> sendAcceptFriendRequest(String userId) async {
    final response = await client.get(backendUri("/friends/$userId"));

    if (response.statusCode == 200) {
      return FriendRead.fromJson(safeJsonDecode((response.body)));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      logger.info(
        "Failed to send/accept friend request: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        'Failed to send/accept friend request',
        response.body,
      );
    }
  }
}
