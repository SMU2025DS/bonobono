import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _keyUserid = 'userid';
  static const String _keyEmail = 'email';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // 로그인 정보 저장
  static Future<void> saveUserInfo(String username, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserid, username);
    await prefs.setString(_keyEmail, email);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  // 로그인 정보 불러오기
  static Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;

    String? username = prefs.getString(_keyUserid);
    String? email = prefs.getString(_keyEmail);

    if (username == null || email == null) return null;

    return {
      'username': username,
      'email': email,
    };
  }

  // 로그아웃 (데이터 삭제)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserid);
    await prefs.remove(_keyEmail);
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}
