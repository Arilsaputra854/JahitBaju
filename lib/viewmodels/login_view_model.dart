import 'package:flutter/material.dart';
import 'package:jahit_baju/model/user.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';

class LoginViewModel extends ChangeNotifier {
  ApiService api = ApiService();

  String? _email;
  String? _password;

  String? _errorMsg;

  String? get email => _email;
  String? get password => _password;
  String? get errorMsg => _errorMsg;

  final TokenStorage _tokenStorage = TokenStorage();

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  Future<bool> login() async {
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

    var response = await api.userLogin(_email!, _password!);

    if (response.error) {
      _errorMsg = response.message;
      notifyListeners();
      return false;
    } else {
      _errorMsg = null;
      await _tokenStorage.saveToken(response.token!);
      notifyListeners();

      return true;
    }
  }

  Future<bool> emailVerified() async {
    var token = await _tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    if (token != null) {
      User user = await api.userGet(token);
      return user.emailVerified;
    }
    return false;
  }
}
