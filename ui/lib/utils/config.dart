import 'package:http/http.dart' as http;
import 'dart:convert';

class Config {
  final String backendBaseUrl;
  final String auth0Domain;
  final String auth0ClientId;

  Config({
    required this.backendBaseUrl,
    required this.auth0Domain,
    required this.auth0ClientId,
  });

  static Future<Config> load() async {
    final response = await http.get(Uri.base.resolve('/config'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      return Config(
        backendBaseUrl: json['BACKEND_BASE_URL'] as String,
        auth0Domain: json['AUTH0_DOMAIN'] as String,
        auth0ClientId: json['AUTH0_CLIENT_ID'] as String,
      );
    } else {
      throw Exception(
        'Failed to load config ${response.statusCode}: ${response.body}',
      );
    }
  }
}
