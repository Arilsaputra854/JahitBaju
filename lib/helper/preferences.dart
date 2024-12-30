

import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveAccessCustom(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('accessCustom', value); // Menyimpan boolean
}


Future<bool?> loadAccessCustom() async {
  final prefs = await SharedPreferences.getInstance();
  bool? accessCustom = prefs.getBool('accessCustom');
  return accessCustom;
}
