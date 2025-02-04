import 'package:flutter/material.dart';
import 'package:jahit_baju/data/model/user.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/user_response.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';

class LoginViewModel extends ChangeNotifier {

  String? _email;
  String? _password;

  String? _message;

  String? get email => _email;
  String? get password => _password;
  String? get message => _message;
  ApiService api;
  LoginViewModel(this.api);

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
      _message = 'Email tidak valid!';
      notifyListeners();
      return false;
    }

    if (_password == null || _password!.length < 8) {
      _message = 'Password harus lebih dari 8 karakter!';
      notifyListeners();
      return false;
    }

    var response = await api.userLogin(_email!, _password!);

    if (response.error) {
      _message = response.message;
      notifyListeners();
      return false;
    } else {
      _message = null;
      await _tokenStorage.saveToken(response.token!);
      notifyListeners();

      return true;
    }
  }

  Future<bool> emailVerified() async {    
    UserResponse response = await api.userGet();

      if(response.error){
        _message = response.message;
        notifyListeners();
        return false;
      }else{
        return response.data?.emailVerified ?? false;
      }
  }
}
