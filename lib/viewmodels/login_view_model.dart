import 'package:flutter/material.dart';
import 'package:jahit_baju/data/model/user.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/user_response.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';

class LoginViewModel extends ChangeNotifier {
  String? _email;
  String? _password;

  String? _message;
  bool _loading = false;
  bool _hidePassword = false;

  String? get email => _email;
  String? get password => _password;
  String? get message => _message;

  bool get loading => _loading;
  bool get hidePassword => _hidePassword;
  ApiService api;
  LoginViewModel(this.api);

  final TokenStorage _tokenStorage = TokenStorage();

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setHidePassword(bool hide){
    _hidePassword = hide;
    notifyListeners();
  }
  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  Future<bool> login() async {
    _loading = true;
    notifyListeners();

    if (_email == null || !_email!.contains('@')) {
      _message = 'Email tidak valid!';
      _loading = false;
      notifyListeners();
      return false;
    }

    if (_password == null || _password!.length < 8) {
      _message = 'Password harus lebih dari 8 karakter!';
      _loading = false;
      notifyListeners();
      return false;
    }

    var response = await api.userLogin(_email!, _password!);

    if (response.error) {
      if (response.message == "User not found") {
        _message = "Alamat email yang kamu masukkan tidak ditemukan.";
        _loading = false;
        notifyListeners();
        return false;
      } else if (response.message == "Email or password is invalid") {
        _message = "Email atau password yang kamu masukkan salah.";
        _loading = false;
        notifyListeners();
        return false;
      } else {
        _message = ApiService.SOMETHING_WAS_WRONG;
        _loading = false;
        notifyListeners();
        return false;
      }
    } else {
      _message = null;
      await _tokenStorage.saveToken(response.token!);
      _loading = false;
      notifyListeners();
      return true;
    }
  }

  Future<bool> emailVerified() async {
    _loading = true;
    notifyListeners();
    UserResponse response = await api.userGet();

    if (response.error) {
      _message = response.message;
      _loading = false;
      notifyListeners();
      return false;
    } else {
      _loading = false;
      notifyListeners();
      return response.data?.emailVerified ?? false;
    }
  }
}
