
import 'package:flutter/material.dart';

class ForgotPasswordViewModel extends ChangeNotifier{

  String? _email;
  String? _errorMsg;


  String? get email => _email;
  String? get errorMsg => _errorMsg;

  void setEmail(String email){
    _email = email;
    notifyListeners();
  }

  Future<void> resetPassword() async{
    if (_email == null || !_email!.contains('@')) {
      _errorMsg = 'Email tidak valid!';
      notifyListeners();
      return;
    }

    _errorMsg = null;
    notifyListeners();

  }
}