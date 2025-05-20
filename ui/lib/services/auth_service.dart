// lib/services/auth_service.dart
import 'package:auth0_flutter/auth0_flutter.dart' show UserProfile;

import 'package:auth0_flutter/auth0_flutter_web.dart' show Auth0Web;

class AuthService {
  final Auth0Web _auth0Web;
  UserProfile? user;

  AuthService(String domain, String clientId)
    : _auth0Web = Auth0Web(domain, clientId);

  Future<void> init() async {
    final credentials = await _auth0Web.onLoad();
    user = credentials?.user;
  }

  bool get isLoggedIn => user != null;

  Future<void> login() async {
    await _auth0Web.loginWithRedirect(redirectUrl: 'http://localhost:3000');
  }

  Future<void> logout() async {
    await _auth0Web.logout(returnToUrl: 'http://localhost:3000');
  }
}
