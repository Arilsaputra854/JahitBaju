import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/api/api_service.dart';
import 'package:jahit_baju/model/user.dart';

class RegisterViewModel extends ChangeNotifier {
  ApiService api = ApiService();

  String? _email;
  String? _password;
  String? _confirmPassword;
  String? _name;
  String? _phoneNumber;

  String? _message;

  String? get email => _email;
  String? get password => _password;
  String? get confirmPassword => _confirmPassword;
  String? get message => _message;
  String? get name => _name;
  String? get phoneNumber => _phoneNumber;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setPhoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setConfirmPassword(String confirmPassword) {
    _confirmPassword = confirmPassword;
    notifyListeners();
  }

  Future<void> register() async {
    if (_email == null || !_email!.contains('@')) {
      _message = 'Email tidak valid!';
      notifyListeners();
      return;
    }

    if (_password == null || _password!.length < 8) {
      _message = 'Password harus lebih dari 8 karakter!';
      notifyListeners();
      return;
    }

    if (_password != _confirmPassword) {
      _message = 'Confirm password tidak sama!';
      notifyListeners();
      return;
    }

    var data = await api.userRegister(_name!, _email!, _phoneNumber!, _password!);

    if (data != null) {
      //if register successfully
      if (data is User) {
        _message = "Register Success!";
        return;
      }

      _message = data.toString();
      return;
    }

    _message = null;
    notifyListeners();
    return;
  }
}
