import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:logging/logging.dart';

class Config {
  final String backendBaseUrl;
  final String auth0Domain;
  final String auth0ClientId;
  final String jwtAudience;

  Config({
    required this.backendBaseUrl,
    required this.auth0Domain,
    required this.auth0ClientId,
    required this.jwtAudience,
  });

  static Future<Config> load() async {
    final Logger logger = Logger("Config");

    logger.info("Sending request to /config");
    final response = await http.get(Uri.base.resolve('/config'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      logger.config("Got the following from /config: $json");

      return Config(
        backendBaseUrl: json['BACKEND_BASE_URL'] as String,
        auth0Domain: json['AUTH0_DOMAIN'] as String,
        auth0ClientId: json['AUTH0_CLIENT_ID'] as String,
        jwtAudience: json['JWT_AUDIENCE'] as String,
      );
    } else {
      throw Exception(
        'Failed to load config ${response.statusCode}: ${response.body}',
      );
    }
  }
}
