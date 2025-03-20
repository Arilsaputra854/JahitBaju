

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {

  static const TOKEN_KEY = "user_token";

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> saveToken(String? token) async{
    if(token != null) {
      await _secureStorage.write(key: TokenStorage.TOKEN_KEY, value: token);
    }
  } 

  Future<String?> readToken(String token) async{
    return await _secureStorage.read(key: TokenStorage.TOKEN_KEY);      
  }

  Future<void> deleteToken(String token) async{  
    await _secureStorage.delete(key: TokenStorage.TOKEN_KEY);
  }
}