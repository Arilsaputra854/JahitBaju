


import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginViewModel extends ChangeNotifier{

  String? _email;
  String? _password;
  String? _errorMsg;

  String? get email => _email;
  String? get password => _password;
  String? get errorMsg => _errorMsg;

  void setEmail(String email){
    _email = email;
    notifyListeners();
  }


  void setPassword(String password){
    _password = password;
    notifyListeners();
  }


  Future<void> Login() async{
    if (_email == null || !_email!.contains('@')) {
      _errorMsg = 'Email tidak valid!';
      notifyListeners();
      return;
    }

    if (_password == null || _password!.length < 8) {
      _errorMsg = 'Password harus lebih dari 8 karakter!';
      notifyListeners();
      return;
    }

    _errorMsg = null;
    notifyListeners();

  }
}