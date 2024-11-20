
import 'package:flutter/material.dart';
import 'package:jahit_baju/api/api_service.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';

class LoginViewModel extends ChangeNotifier {
  ApiService api = ApiService();

  String? _email;
  String? _password;

  String? _errorMsg;

  String? get email => _email;
  String? get password => _password;
  String? get errorMsg => _errorMsg;

  TokenStorage _tokenStorage = TokenStorage();

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  Future<bool> Login() async {
    if (_email == null || !_email!.contains('@')) {
      _errorMsg = 'Email tidak valid!';
      notifyListeners();
      return false;
    }

    if (_password == null || _password!.length < 8) {
      _errorMsg = 'Password harus lebih dari 8 karakter!';
      notifyListeners();
      return false;
    }

    var status = await api.userLogin(_email!, _password!);
    
    if (status != null && status.startsWith("Email")) {
      _errorMsg = status; // Tampilkan pesan error
      notifyListeners();
      return false; // Kembalikan string kosong jika error
    } 
      _errorMsg = null;
      print(status);
      await _tokenStorage.saveToken(status!);      
      
      notifyListeners();

      return true;
    
  }
}
