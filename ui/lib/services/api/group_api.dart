import 'dart:convert';

import 'package:flutter_frontend/models/enums.dart' show GroupRole;
import 'package:flutter_frontend/models/expense.dart';
import 'package:flutter_frontend/models/group.dart';
import 'package:flutter_frontend/models/user.dart';
import 'package:flutter_frontend/services/api/common.dart';
import 'package:flutter_frontend/services/api_service.dart' show ApiException;

class GroupApiClient extends BaseApiClient {
  GroupApiClient(super.client, super.baseUrl, super.logger);

  Future<List<GroupUserRead>> getUserGroups() async {
    final response = await client.get(backendUri("/groups"));

    if (response.statusCode == 200) {
      return safeJsonDecodeList(response.body, GroupUserRead.fromJson);
    } else {
      logger.info(
        "Failed to get user's groups: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        "Failed to fetch user's groups",
        response.body,
      );
    }
  }

  Future<GroupRead?> getGroup(String groupId) async {
    final response = await client.get(backendUri("/groups/$groupId"));

    if (response.statusCode == 200) {
      return GroupRead.fromJson(safeJsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      logger.info(
        "Failed to get group: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        "Failed to get group",
        response.body,
      );
    }
  }

  Future<GroupRead> createGroup(GroupCreate body) async {
    final response = await client.post(
      backendUri("/groups"),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return GroupRead.fromJson(safeJsonDecode(response.body));
    } else {
      logger.info(
        "Failed to create group: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        "Failed to create group",
        response.body,
      );
    }
  }

  Future<GroupRead> updateGroup(String groupId, GroupCreate body) async {
    final response = await client.put(
      backendUri("/groups/$groupId"),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return GroupRead.fromJson(safeJsonDecode(response.body));
    } else {
      logger.info(
        "Failed to update group: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        "Failed to update group",
        response.body,
      );
    }
  }

  Future<List<UserGroupRead>> getGroupUsers(String groupId) async {
    final response = await client.get(backendUri("/groups/$groupId/users"));

    if (response.statusCode == 200) {
      return safeJsonDecodeList(response.body, UserGroupRead.fromJson);
    } else {
      logger.info(
        "Failed to get a groups users: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        "Failed to get a groups users",
        response.body,
      );
    }
  }

  Future<UserGroupRead> createUpdateGroupUser(
    String groupId,
    String userId,
    GroupRole role,
  ) async {
    final response = await client.put(
      // backendUri("/groups/$groupId/users/$userId?role=$role"),
      backendUri("/groups/$groupId/users/$userId?role=${role.label}"),
    );

    if (response.statusCode == 200) {
      return UserGroupRead.fromJson(safeJsonDecode(response.body));
    } else {
      logger.info(
        "Failed to create/update group user: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        "Failed to create/update group user",
        response.body,
      );
    }
  }

  Future<UserGroupRead> deleteGroupUser(String groupId, String userId) async {
    final response = await client.delete(
      backendUri("/groups/$groupId/users/$userId"),
    );

    if (response.statusCode == 200) {
      return UserGroupRead.fromJson(safeJsonDecode(response.body));
    } else {
      logger.info(
        "Failed to remove group user: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        "Failed to remove group user",
        response.body,
      );
    }
  }

  Future<List<ExpenseRead>> getGroupExpenses(String groupId) async {
    final response = await client.get(backendUri("/groups/$groupId/expenses"));

    if (response.statusCode == 200) {
      return safeJsonDecodeList(response.body, ExpenseRead.fromJson);
    } else {
      logger.info(
        "Failed to get a groups expenses: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        "Failed to get a groups expenses",
        response.body,
      );
    }
  }
}
