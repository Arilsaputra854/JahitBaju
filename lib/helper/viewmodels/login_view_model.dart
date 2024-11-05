import 'dart:convert';
import 'dart:developer';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jahit_baju/helper/api/api_service.dart';

class LoginViewModel extends ChangeNotifier {
  ApiService api = ApiService();

  String? _email;
  String? _password;

  String? _errorMsg;

  String? get email => _email;
  String? get password => _password;
  String? get errorMsg => _errorMsg;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  Future<String> Login() async {
    if (_email == null || !_email!.contains('@')) {
      _errorMsg = 'Email tidak valid!';
      notifyListeners();
      return "";
    }

    if (_password == null || _password!.length < 8) {
      _errorMsg = 'Password harus lebih dari 8 karakter!';
      notifyListeners();
      return "";
    }

    var status = await api.login(_email!, _password!);

    print(status);
    if (status != null && status.startsWith("Email")) {
      _errorMsg = status; // Tampilkan pesan error
      notifyListeners();
      return ""; // Kembalikan string kosong jika error
    } else {
      //TODO
      _errorMsg = null;
      notifyListeners();
      return status!;
    }
  }
}
