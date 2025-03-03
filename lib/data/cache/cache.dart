import 'dart:convert';
import 'package:logger/web.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  Logger log = Logger();
  static const String KEY = "TEXTURE_MAP_CUSTOM";

  Future<void> saveBase64Map(Map<String, String> base64Map) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonMap = jsonEncode(base64Map);
    log.d("Save Texture Cache ${jsonMap}");
    await prefs.setString(KEY, jsonMap);
  }

  Future<Map<String, String>?> getBase64Map() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonMap = prefs.getString(KEY);
    log.d("Read Texture Cache ${jsonMap}");
    if (jsonMap != null) {
      return Map<String, String>.from(jsonDecode(jsonMap));
    }
    return null;
  }

  Future<void> removeBase64Map() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KEY);
  }
}
