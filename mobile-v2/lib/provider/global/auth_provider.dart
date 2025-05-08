import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  // Fields
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  bool _isChecking = false;
  bool _isFirstTime = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  bool get isChecking => _isChecking;
  bool get isFirstTime => _isFirstTime;

  // Services
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();

  // Constructor
  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    await _checkFirstTimeLaunch();
    await handleCheckAuth();
  }

  Future<void> _checkFirstTimeLaunch() async {
    final hasLaunched = await _storage.read(key: 'has_launched');
    if (hasLaunched == null) {
      _isFirstTime = true;
      await _storage.write(key: 'has_launched', value: 'true');
    } else {
      _isFirstTime = false;
    }
  }

  // Login
  Future<void> handleLogin({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _authService.login(username: username, password: password);
      await saveAuthData(data['data']);
      _isLoggedIn = true;
    } catch (e) {
      _error = "Invalid Credential.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> handleLogout() async {
    _isLoggedIn = false;
    await _storage.delete(key: 'token');
    notifyListeners();
  }

  // Auth Check
  Future<void> handleCheckAuth() async {
    _isChecking = true;
    notifyListeners();
    try {
      _isLoggedIn = await _validateToken();
    } catch (e) {
      _isLoggedIn = false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  Future<bool> _validateToken() async {
    try {
      return await _authService.checkAuth();
    } catch (e) {
      return false;
    }
  }

  // Save Auth Data
  Future<void> saveAuthData(Map<String, dynamic> data) async {
    try {
      final user = data['user'];
      final roles = user['roles'] as List<dynamic>;

      await _storage.write(key: 'token', value: data['access_token'] ?? '');
      await _storage.write(key: 'id', value: user['id'].toString());
      await _storage.write(key: 'name', value: user['name'] ?? '');
      await _storage.write(key: 'phone', value: user['phone'] ?? '');
      await _storage.write(key: 'email', value: user['email'] ?? '');
      await _storage.write(key: 'avatar', value: user['avatar'] ?? '');

      final defaultRole = roles.firstWhere(
        (role) => role['is_default'] == true,
        orElse: () => roles.isNotEmpty ? roles[0] : null,
      );

      if (defaultRole != null) {
        await _storage.write(key: 'role_id', value: defaultRole['id'].toString());
        await _storage.write(key: 'role_name', value: defaultRole['name'] ?? '');
        await _storage.write(key: 'role_slug', value: defaultRole['slug'] ?? '');
      }

      await _storage.write(key: 'roles', value: roles.toString());
    } catch (e) {
      rethrow;
    }
  }
}
