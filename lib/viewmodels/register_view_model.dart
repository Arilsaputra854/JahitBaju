import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/model/user.dart';
import 'package:jahit_baju/data/source/remote/response/register_response.dart';

class RegisterViewModel extends ChangeNotifier {
  ApiService apiService;

  String? _email;
  String? _password;
  String? _confirmPassword;
  String? _name;
  String? _phoneNumber;

  String? _message;

  bool _isLoading = false;

  String? get email => _email;
  String? get password => _password;
  String? get confirmPassword => _confirmPassword;
  String? get message => _message;
  bool get isLoading => _isLoading;
  String? get name => _name;
  String? get phoneNumber => _phoneNumber;

  RegisterViewModel(this.apiService);

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
    _isLoading = true;
    notifyListeners();

    if (_email == null || !_email!.contains('@')) {
      _message = 'Email yang kamu masukkan tidak valid!';
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (_password == null || _password!.length < 8) {
      _message = 'Password harus lebih dari 8 karakter!';
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (_password != _confirmPassword) {
      _message = 'Konfirmasi password tidak sama!';
      _isLoading = false;
      notifyListeners();
      return;
    }

    RegisterResponse data = await apiService.userRegister(
        _name!, _email!, _phoneNumber!, _password!);

    if (data.error) {
      if (data.message != null) {
        if (data.message == RegisterResponse.EMAIL_ALREADY_EXIST) {
          _message = "Alamat email kamu sudah terdaftar.";
          _isLoading = false;
          notifyListeners();
          return;
        } else {
          _isLoading = false;
          _message = null;
          notifyListeners();
          return;
        }
      }
    } else {
      //if register successfully
      if (data.user != null) {
        _isLoading = false;
        _message = "Buat akun berhasil!";
        notifyListeners();
        return;
      } else {
        _isLoading = false;
        _message = ApiService.SOMETHING_WAS_WRONG;
        notifyListeners();
        return;
      }
    }
    _message = null;
    _isLoading = false;
    notifyListeners();
    return;
  }
}
