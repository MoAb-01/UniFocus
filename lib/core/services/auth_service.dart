import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSession {
  final String userId;
  final String email;
  final String accessToken;
  final DateTime accessTokenExpiry;
  final String refreshToken;
  final DateTime refreshTokenExpiry;

  AuthSession({
    required this.userId,
    required this.email,
    required this.accessToken,
    required this.accessTokenExpiry,
    required this.refreshToken,
    required this.refreshTokenExpiry,
  });

  bool get isAccessTokenExpired => DateTime.now().isAfter(accessTokenExpiry);
  bool get isRefreshTokenExpired => DateTime.now().isAfter(refreshTokenExpiry);
}

class AuthService extends ChangeNotifier {
  static const String _keyRefreshToken = 'auth_secure_refresh_token';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUserEmail = 'auth_user_email';
  static const String _keyLastActivity = 'auth_last_activity';

  static const Duration _accessTokenTtl = Duration(minutes: 30);
  static const Duration _refreshTokenTtl = Duration(days: 14);
  static const Duration _inactivityLimit = Duration(days: 7);

  String? _inMemoryAccessToken;
  DateTime? _accessTokenExpiry;
  String? _currentUserId;
  String? _currentUserEmail;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserId => _currentUserId;
  String? get currentUserEmail => _currentUserEmail;
  String? get inMemoryAccessToken => _inMemoryAccessToken;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_keyRefreshToken);
    final userId = prefs.getString(_keyUserId);
    final userEmail = prefs.getString(_keyUserEmail);
    final lastActivityStr = prefs.getString(_keyLastActivity);

    if (refreshToken != null && userId != null) {
      if (lastActivityStr != null) {
        final lastActivity = DateTime.parse(lastActivityStr);
        if (DateTime.now().difference(lastActivity) > _inactivityLimit) {
          // Expired due to inactivity
          await logout();
          return;
        }
      }

      // Perform silent renewal using refresh token
      _currentUserId = userId;
      _currentUserEmail = userEmail ?? 'mohamed.abdou@ikcu.edu.tr';
      final renewed = await silentRenewToken(refreshToken);
      if (renewed) {
        _isAuthenticated = true;
        _touchActivity();
      } else {
        await logout();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    // In mock/local production environment, validate credentials
    if (email.isNotEmpty && password.length >= 6) {
      final now = DateTime.now();
      _currentUserId = 'user_${email.hashCode}';
      _currentUserEmail = email;

      // Dual-token architecture
      _inMemoryAccessToken = 'at_${DateTime.now().microsecondsSinceEpoch}';
      _accessTokenExpiry = now.add(_accessTokenTtl);

      final newRefreshToken = 'rt_${DateTime.now().microsecondsSinceEpoch}_${_currentUserId}';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyRefreshToken, newRefreshToken);
      await prefs.setString(_keyUserId, _currentUserId!);
      await prefs.setString(_keyUserEmail, _currentUserEmail!);
      await _touchActivity();

      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      return login(email, password);
    }
    return false;
  }

  /// Catches 401 Unauthorized and silently uses Refresh Token to obtain a new Access Token.
  Future<bool> silentRenewToken([String? tokenToUse]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = tokenToUse ?? prefs.getString(_keyRefreshToken);
      if (refreshToken == null) return false;

      // Simulate Token Rotation on refresh
      final now = DateTime.now();
      _inMemoryAccessToken = 'at_renewed_${now.microsecondsSinceEpoch}';
      _accessTokenExpiry = now.add(_accessTokenTtl);

      final rotatedRefreshToken = 'rt_rot_${now.microsecondsSinceEpoch}';
      await prefs.setString(_keyRefreshToken, rotatedRefreshToken);
      await _touchActivity();

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    _inMemoryAccessToken = null;
    _accessTokenExpiry = null;
    _currentUserId = null;
    _currentUserEmail = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyLastActivity);

    notifyListeners();
  }

  Future<void> _touchActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastActivity, DateTime.now().toIso8601String());
  }
}
