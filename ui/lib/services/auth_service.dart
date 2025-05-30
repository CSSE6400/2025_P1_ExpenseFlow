// lib/services/auth_service.dart
import 'package:auth0_flutter/auth0_flutter.dart' show UserProfile;
import 'package:http/http.dart' as http;

import 'package:auth0_flutter/auth0_flutter_web.dart' show Auth0Web;
import 'package:logging/logging.dart' show Logger;

class AuthenticatedClient extends http.BaseClient {
  final http.Client _client;
  final AuthService authService;

  AuthenticatedClient(this.authService) : _client = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await authService.getAccessToken();
    if (token == null) {
      throw Exception('No access token found. Please log in.');
    }
    request.headers["Authorization"] = "Bearer $token";
    request.headers["Content-Type"] = "application/json";
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
    super.close();
  }
}

class AuthService {
  final String audience;
  final Auth0Web _auth0Web;
  UserProfile? user;

  late final AuthenticatedClient _authenticatedClient;
  AuthenticatedClient get authenticatedClient => _authenticatedClient;

  final _logger = Logger("Auth Service");

  AuthService(String domain, String clientId, this.audience)
    : _auth0Web = Auth0Web(domain, clientId) {
    _authenticatedClient = AuthenticatedClient(this);
  }

  Future<String?> getAccessToken() async {
    try {
      final credentials = await _auth0Web.credentials(audience: audience);
      user = credentials.user;
      return credentials.accessToken;
    } catch (e) {
      _logger.warning('Failed to get access token: $e');
      return null;
    }
  }

  Future<void> init() async {
    _logger.info("Getting credentials auth service");
    try {
      final credentials = await _auth0Web.onLoad(audience: audience);
      user = credentials?.user;
      _logger.info("User restored silently: ${user?.name}");
    } catch (e) {
      _logger.warning("Failed to initialise AuthService: $e");
    }
  }

  bool get isLoggedIn => user != null;

  Future<void> login() async {
    try {
      await _auth0Web.loginWithRedirect(
        redirectUrl: Uri.base.resolve("/").toString(),
        audience: audience,
      );
    } catch (e) {
      _logger.severe(e);
    }
  }

  Future<void> logout() async {
    try {
      await _auth0Web.logout(returnToUrl: Uri.base.resolve("/").toString());
    } catch (e) {
      _logger.severe(e);
    }
  }
}
