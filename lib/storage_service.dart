import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _customTextKey = 'custom_text';
  static const String _shakeEnabledKey = 'shake_enabled';

  // Custom Text Operations
  static Future<String> loadCustomText() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_customTextKey) ?? 'Custom Text';
  }

  static Future<void> saveCustomText(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customTextKey, text);
  }

  // Shake Feature Operations
  static Future<bool> loadShakeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_shakeEnabledKey) ?? true;
  }

  static Future<void> saveShakeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shakeEnabledKey, enabled);
  }
}
