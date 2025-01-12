import 'package:shared_preferences/shared_preferences.dart';

class User {
  static const String _keyUserName = 'userName';

  static Future<void> saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, userName);
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName) ?? '';
  }

  static Future<void> removeUserName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserName);
  }

  static Future<bool> isUserNameSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUserName);
  }
}
