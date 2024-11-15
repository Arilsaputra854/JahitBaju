import 'package:flutter/material.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  String? _password;
  String? _confirmPassword;
  String? _errorMsg;

  String? get password => _password;
  String? get confirmPassword => _confirmPassword;
  String? get errorMsg => _errorMsg;

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setConfirmPassword(String confirmPassword) {
    _confirmPassword = confirmPassword;
    notifyListeners();
  }

  Future<void> changePassword() async {
    if (_password == null || _confirmPassword == null) {
      _errorMsg = 'Password tidak boleh kosong!';
      notifyListeners();
      return;
    }

    if (_password != _confirmPassword) {
      _errorMsg = 'Konfirmasi password tidak sama!';
      notifyListeners();
      return;
    }


    if (_password!.length < 7) {
      _errorMsg = 'Password harus terdiri dari minimal 8 karakter!';
      notifyListeners();
      return;
    }

    _errorMsg = null;
    notifyListeners();
  }
}
