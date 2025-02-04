import 'package:flutter/material.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/login_response.dart';
import 'package:jahit_baju/util/util.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  String? _email;
  String? _errorMsg;
  bool _isLoading = false;

  bool? get isLoading => _isLoading;
  String? get email => _email;
  String? get errorMsg => _errorMsg;


  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  Future<void> resetPassword() async {
    _isLoading = true;
    notifyListeners();

    await checkInternetConnection().then((isConnected) async {
      if (isConnected) {
        if (_email == null || !_email!.contains('@')) {
          _isLoading = false;
          _errorMsg = 'Email yang kamu masukkan tidak valid.';
          notifyListeners();
          return;
        } else {
          
            _isLoading = false;
            _errorMsg = null;
            notifyListeners();
        }
      } else {
        _isLoading = false;
        _errorMsg =
            'Tidak dapat mengatur ulang password karena kamu sedang offline.';
        notifyListeners();
        return;
      }
    });
  }
}
