import 'package:flutter/material.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/service/remote/response/user_response.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  String? _password;
  String? _confirmPassword;
  String? _errorMsg;

  String? get password => _password;
  String? get confirmPassword => _confirmPassword;
  String? get errorMsg => _errorMsg;


  ApiService apiService = ApiService();

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setConfirmPassword(String confirmPassword) {
    _confirmPassword = confirmPassword;
    notifyListeners();
  }

  Future<void> changePassword(String token) async {

      _errorMsg = null;
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

    UserResponse userResponse =  await apiService.userUpdate(null, null, password, null, null, null, resetToken: token);

    if(userResponse.error){
      _errorMsg = userResponse.message!;
    }
    
    notifyListeners();
  }
}
