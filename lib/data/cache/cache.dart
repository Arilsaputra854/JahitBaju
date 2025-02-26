import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static Future<void> saveBase64List(String key, List<String> base64List) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, base64List);
  }

  static Future<List<String>?> getBase64List(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  static Future<void> removeBase64List(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
