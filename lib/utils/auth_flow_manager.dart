import 'package:shared_preferences/shared_preferences.dart';

class AuthFlowManager {
  static const String _stayOnHomeAfterLogoutKey = 'stayOnHomeAfterLogout';

  static Future<void> setStayOnHomeAfterLogout(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_stayOnHomeAfterLogoutKey, value);
  }

  static Future<bool> shouldStayOnHomeAfterLogout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_stayOnHomeAfterLogoutKey) ?? false;
  }
}
