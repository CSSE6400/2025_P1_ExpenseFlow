import 'dart:convert';

import 'package:flutter_frontend/models/expense.dart';
import 'package:flutter_frontend/models/user.dart' show UserCreate, UserRead;
import 'package:flutter_frontend/services/auth_service.dart'
    show AuthenticatedClient;
import 'package:logging/logging.dart' show Logger;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? responseBody;

  ApiException(this.statusCode, this.message, [this.responseBody]);

  @override
  String toString() {
    return 'ApiException: [$statusCode] $message'
        '${responseBody != null ? '\nResponse Body: $responseBody' : ''}';
  }
}

class ApiService {
  final AuthenticatedClient client;
  final String baseUrl;
  final Logger _logger = Logger("ApiService");

  ApiService(this.client, this.baseUrl);

  Uri backendUri(String path) => Uri.parse("$baseUrl$path");

  dynamic _safeJsonDecode(String source) {
    try {
      return jsonDecode(source);
    } catch (e) {
      throw FormatException('Failed to decode JSON: $e\nRaw: $source');
    }
  }

  Future<UserRead?> getCurrentUser() async {
    final response = await client.get(backendUri("/users"));

    switch (response.statusCode) {
      case 200:
        return UserRead.fromJson(_safeJsonDecode(response.body));
      case 401:
        return null;
      default:
        _logger.info(
          "Failed to fetch current user: ${response.statusCode} ${response.body}",
        );
        throw ApiException(
          response.statusCode,
          "Failed to fetch current user",
          response.body,
        );
    }
  }

  Future<bool> checkNicknameExists(String nickname) async {
    final response = await client.get(
      backendUri("/users/nickname-taken?nickname=$nickname"),
    );
    if (response.statusCode == 200) {
      return response.body == "true";
    } else {
      _logger.info(
        "Failed to check if nickname exists: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        'Failed to create user',
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
      return UserRead.fromJson(_safeJsonDecode((response.body)));
    } else {
      _logger.info(
        "Failed to create user: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        'Failed to create user',
        response.body,
      );
    }
  }

  Future<ExpenseRead> createExpense(ExpenseCreate body) async {
    final response = await client.post(
      backendUri("/expenses"),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      // parse response body to ExpenseRead
      return ExpenseRead.fromJson(_safeJsonDecode((response.body)));
    } else {
      _logger.info(
        "Failed to create expense: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        'Failed to create expense',
        response.body,
      );
    }
  }

  Future<List<ExpenseRead>> getExpensesUploadedByMe() async {
    final response = await client.get(backendUri("/expenses"));

    if (response.statusCode == 200) {
      // parse response body to List<ExpenseRead>
      return (jsonDecode(response.body) as List)
          .map((e) => ExpenseRead.fromJson(e))
          .toList();
    } else {
      _logger.info(
        "Failed to fetch expenses: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        'Failed to fetch expenses',
        response.body,
      );
    }
  }
}
