import 'dart:convert';

import 'package:flutter_frontend/models/user.dart' show UserCreate, UserRead;
import 'package:flutter_frontend/services/auth_service.dart'
    show AuthenticatedClient;

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

  ApiService(this.client, this.baseUrl);

  Uri backendUri(String path) => Uri.parse("$baseUrl$path");

  Future<UserRead?> getCurrentUser() async {
    final response = await client.get(backendUri("/users"));

    switch (response.statusCode) {
      case 200:
        return UserRead.fromJson(jsonDecode(response.body));
      case 401:
        return null;
      default:
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
      return UserRead.fromJson(jsonDecode((response.body)));
    } else {
      throw ApiException(
        response.statusCode,
        'Failed to create user',
        response.body,
      );
    }
  }
}
