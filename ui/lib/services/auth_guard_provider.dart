import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/api_service.dart';
import 'package:flutter_frontend/services/auth_service.dart';
import 'package:flutter_frontend/models/user.dart' show UserRead;
import 'package:logging/logging.dart';

class AuthGuardProvider extends ChangeNotifier {
  final AuthService _authService;
  final ApiService _apiService;
  final Logger _logger = Logger('AuthGuardProvider');

  UserRead? _user;
  UserRead? get user => _user;

  bool _loading = true;
  bool get loading => _loading;

  Timer? _refreshTimer;

  AuthGuardProvider(this._authService, this._apiService) {
    _init();
  }

  Future<void> _init() async {
    _loading = true;
    notifyListeners();

    WidgetsBinding.instance.addObserver(
      _AppLifecycleObserver(
        onResume: () {
          _logger.info("App resumed, refreshing user.");
          refreshUser(force: true);
        },
      ),
    );

    await _checkAuthAndLoadUser();

    _loading = false;
    notifyListeners();

    _startAutoRefreshTimer();
  }

  Future<void> _checkAuthAndLoadUser() async {
    if (!_authService.isLoggedIn) {
      _logger.info("User not logged in.");
      _user = null;
      return;
    }

    try {
      final currentUser = await _apiService.userApi.getCurrentUser();
      if (currentUser == null) {
        _logger.info("User logged in but profile not set up.");
        _user = null;
      } else {
        _logger.info("User loaded: ${currentUser.nickname}");
        _user = currentUser;
      }
    } catch (e) {
      _logger.warning("Failed to load user: $e");
      _user = null;
    }
  }

  Future<void> refreshUser({bool force = false}) async {
    if (!force && _loading) return; // avoid refresh

    _loading = true;
    notifyListeners();

    try {
      // attempt to get token first
      final token = await _authService.getAccessToken();

      if (token == null) {
        _logger.info("Token expired or missing, logging out.");
        await logoutAndRedirect();
        return;
      }

      final currentUser = await _apiService.userApi.getCurrentUser();

      if (currentUser == null) {
        _logger.info("User profile missing after refresh.");
        _user = null;
      } else {
        _user = currentUser;
      }
    } catch (e) {
      _logger.warning("Error refreshing user: $e");
      _user = null;
      await logoutAndRedirect();
    } finally {
      Future.microtask(() {
        _loading = false;
        notifyListeners();
      });
    }
  }

  void _startAutoRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      refreshUser(force: true);
    });
  }

  Future<void> logoutAndRedirect() async {
    await _authService.logout();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(
      _AppLifecycleObserver(onResume: () {}),
    );
    super.dispose();
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResume;
  _AppLifecycleObserver({required this.onResume});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResume();
    }
  }
}
