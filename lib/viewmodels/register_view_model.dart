import 'package:flutter/material.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/register_response.dart';

class RegisterViewModel extends ChangeNotifier {
  ApiService apiService;

  String? _email;
  String? _password;
  String? _confirmPassword;
  String? _name;
  String? _phoneNumber;

  String? _message;
  bool _loading = false;
  bool _hidePassword = false;
  bool _agreeTerm = false;
  

  String? get email => _email;
  String? get password => _password;
  String? get confirmPassword => _confirmPassword;
  String? get message => _message;
  String? get name => _name;
  String? get phoneNumber => _phoneNumber;


  bool get agreeTerm => _agreeTerm;
  bool get hidePassword => _hidePassword;
  bool get loading => _loading;

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

  void setHidePassword(bool hide){
    _hidePassword = hide;
    notifyListeners();
  }

  void setAgreeTerm(bool? agree){
    _agreeTerm = agree ?? false;
    notifyListeners();
  }

  Future<void> register() async {
    _loading = true;
    notifyListeners();

    if (_email == null || !_email!.contains('@')) {
      _message = 'Email yang kamu masukkan tidak valid!';
      _loading = false;
      notifyListeners();
      return;
    }

    if (_password == null || _password!.length < 8) {
      _message = 'Password harus lebih dari 8 karakter!';
      _loading = false;
      notifyListeners();
      return;
    }

    if (_password != _confirmPassword) {
      _message = 'Konfirmasi password tidak sama!';
      _loading = false;
      notifyListeners();
      return;
    }

    RegisterResponse data = await apiService.userRegister(
        _name!, _email!, _phoneNumber!, _password!);

    if (data.error) {
      if (data.message != null) {
        if (data.message == RegisterResponse.EMAIL_ALREADY_EXIST) {
          _message = "Alamat email kamu sudah terdaftar.";
          _loading = false;
          notifyListeners();
          return;
        } else {
          _loading = false;
          _message = null;
          notifyListeners();
          return;
        }
      }
    } else {
      //if register successfully
      if (data.user != null) {
        _loading = false;
        _message = "Buat akun berhasil!";
        notifyListeners();
        return;
      } else {
        _loading = false;
        _message = ApiService.SOMETHING_WAS_WRONG;
        notifyListeners();
        return;
      }
    }
    _message = null;
    _loading = false;
    notifyListeners();
    return;
  }
}
