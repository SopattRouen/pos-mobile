import 'dart:developer';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/entity/model/user.dart'; // Ensure this path is correct

class UserPreferences {
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save user data from JWT token
  static Future<void> saveUserFromToken(String token) async {
    await init();

    try {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      var userData = payload['user'];
      // Avoid logging sensitive information
      log("User data extracted for saving.");

      await _prefs!.setInt('user.id', userData['id'] ?? 0);
      await _prefs!.setString('user.name', userData['name'] ?? '');
      await _prefs!.setString('user.phone', userData['phone'] ?? '');
      await _prefs!.setString('user.email', userData['email'] ?? '');
      await _prefs!.setString('user.avatar', userData['avatar'] ?? '');
      await _prefs!.setString('user.token', token);

      if (userData['roles'] != null && userData['roles'].isNotEmpty) {
        await _prefs!.setString('user.role', userData['roles'][0]['name'] ?? 'defaultRole');
      }
    } catch (e) {
      log('Error saving user from token: $e');
      throw Exception('Failed to decode token or save user data');
    }
  }

  static Future<User?> getUser() async {
    await init();
    try {
      return User(
        id: _prefs!.getInt('user.id') ?? 0,
        name: _prefs!.getString('user.name') ?? '',
        phone: _prefs!.getString('user.phone') ?? '',
        email: _prefs!.getString('user.email') ?? '',
        avatar: _prefs!.getString('user.avatar') ?? '',
        token: _prefs!.getString('user.token') ?? '',
      );
    } catch (e) {
      log('Error retrieving user: $e');
      return null;
    }
  }

  static Future<void> clearUserPreferences() async {
    await init();
    await _prefs!.clear();
  }

  static Future<String> getUserToken() async {
    await init();
    return _prefs!.getString('user.token') ?? '';
  }
}
