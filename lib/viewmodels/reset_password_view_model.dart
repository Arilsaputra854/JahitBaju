import 'package:flutter/material.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/user_response.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  String? _password;
  String? _confirmPassword;
  String? _message;

  String? get password => _password;
  String? get confirmPassword => _confirmPassword;
  String? get message => _message;

  ApiService apiService;

  ResetPasswordViewModel(this.apiService);

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setConfirmPassword(String confirmPassword) {
    _confirmPassword = confirmPassword;
    notifyListeners();
  }

  Future<void> changePassword(String token) async {

    _message = null;
    notifyListeners();
    
    if (_password == null || _confirmPassword == null) {
      _message = 'Password tidak boleh kosong!';
      notifyListeners();
      return;
    }

    if (_password != _confirmPassword) {
      _message = 'Konfirmasi password tidak sama!';
      notifyListeners();
      return;
    }


    if (_password!.length < 7) {
      _message = 'Password harus terdiri dari minimal 8 karakter!';
      notifyListeners();
      return;
    }

    UserResponse userResponse =  await apiService.userUpdate(null, null, password, null, null, null, resetToken: token);

    if(userResponse.error){
      _message = userResponse.message!;
      notifyListeners();
      return;
    }
  }
}
