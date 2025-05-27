import 'dart:convert' show jsonDecode;

import 'package:flutter_frontend/services/auth_service.dart'
    show AuthenticatedClient;
import 'package:logging/logging.dart' show Logger;

abstract class BaseApiClient {
  final AuthenticatedClient client;
  final String baseUrl;
  final Logger logger;

  BaseApiClient(this.client, this.baseUrl, this.logger);

  Uri backendUri(String path) => Uri.parse("$baseUrl$path");

  dynamic safeJsonDecode(String source) {
    try {
      return jsonDecode(source);
    } catch (e) {
      throw FormatException('Failed to decode JSON: $e\nRaw: $source');
    }
  }
}
