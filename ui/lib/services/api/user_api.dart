import 'dart:convert';

import 'package:flutter_frontend/models/user.dart' show UserCreate, UserRead;
import 'package:flutter_frontend/services/api/common.dart';
import 'package:flutter_frontend/services/api_service.dart' show ApiException;

class UserApiClient extends BaseApiClient {
  UserApiClient(super.client, super.baseUrl, super.logger);

  Future<UserRead?> getCurrentUser() async {
    final response = await client.get(backendUri("/users"));

    switch (response.statusCode) {
      case 200:
        return UserRead.fromJson(safeJsonDecode(response.body));
      case 401:
        return null;
      default:
        logger.info(
          "Failed to fetch current user: ${response.statusCode} ${response.body}",
        );
        throw ApiException(
          response.statusCode,
          "Failed to fetch current user",
          response.body,
        );
    }
  }

  Future<UserRead> createUser(UserCreate body) async {
    final response = await client.post(
      backendUri("/users"),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      // parse response body to UserRead
      return UserRead.fromJson(safeJsonDecode((response.body)));
    } else {
      logger.info(
        "Failed to create user: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        'Failed to create user',
        response.body,
      );
    }
  }

  Future<bool> checkNicknameExists(String nickname) async {
    final response = await client.get(
      backendUri("/users/nickname-taken?nickname=$nickname"),
    );
    if (response.statusCode == 200) {
      return safeJsonDecode(response.body) as bool;
    } else {
      logger.info(
        "Failed to check if nickname exists: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        'Failed to check nickname existence',
        response.body,
      );
    }
  }
}
