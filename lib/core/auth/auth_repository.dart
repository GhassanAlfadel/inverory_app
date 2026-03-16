import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static const String _isLoggedInKey = 'is_logged_in';

  Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> logout() async {
    await setLoggedIn(false);
  }
}
