import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/login_response.dart';
import 'package:jahit_baju/data/source/remote/response/otp_response.dart';
import 'package:jahit_baju/views/otp_screen/otp_screen.dart';

class OtpScreenViewModel extends ChangeNotifier {
  String? _message;
  bool _loading = false;
  bool _isRequestOtp = true;
  String? _email;
  int? _otp;
  int _secondsRemaining = 300;
  ApiService apiService;
  Timer? _timer;

  OtpScreenViewModel(this.apiService);

  bool get loading => _loading;
  int? get otp => _otp;
  int get secondsRemaining => _secondsRemaining;
  String? get email => _email;
  bool get isRequestOtp => _isRequestOtp;
  String? get message => _message;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setOtp(int otp) {
    _otp = otp;
    notifyListeners();
  }


  Future<void> sendOtpVerification(int type) async {
    if (email != null) {
      if (type == OtpScreen.RESET_PASSWORD) {
        LoginResponse response = await apiService.userResetRequestOtp(email!);

        if (response.error) {
          if (response.message!.contains(
              "OTP is already valid and not expired. Please verify it.")) {
            _message = "Kode OTP masih valid. silakan cek email kamu.";

            
            _isRequestOtp = false;
            notifyListeners();

            startCountdown();
          }
          if (response.message!.contains("User not found.")) {
            _message = "Email yang kamu masukkan tidak ditemukan.";

            _isRequestOtp = true;
            notifyListeners();
          }
          if (response.message!.contains("OTP has expired")) {
              resetTimer();
              _message = "Kode OTP telah kadaluarsa.";
              _isRequestOtp = true;
              notifyListeners();
          }
        } else {
          if (response.message!
              .contains("OTP has been successfully sent to your email.")) {
            _message = "Kode OTP berhasil dikirim.";
            _isRequestOtp = false;
            notifyListeners();
          }
          startCountdown();
        }
      } else if (type == OtpScreen.REGISTER) {
        OtpResponse response = await apiService.userRequestOtp();

        if (response.error) {
          if (response.message!.contains("User not found.")) {
            _message = "Email yang kamu masukkan tidak ditemukan.";

            _isRequestOtp = true;
            notifyListeners();
          }
          if (response.message!.contains(
              "OTP is already valid and not expired. Please verify it.")) {
            _message = "Kode OTP masih valid. silakan cek email kamu.";

            _isRequestOtp = false;
            notifyListeners();

            startCountdown();
          }
          if (response.message!.contains("OTP has expired")) {
              resetTimer();
              _message = "Kode OTP telah kadaluarsa.";
              _isRequestOtp = true;
              notifyListeners();
          }
        } else {
          if (response.message!
              .contains("OTP has been successfully sent to your email.")) {
            _message = "Kode OTP berhasil dikirim.";
            _isRequestOtp = false;
            notifyListeners();
          }
          startCountdown();
        }
      }
      ;
    }
  }


  Future<dynamic> verifyOtpVerification(int type) async {
    if (email != null) {
      if (type == OtpScreen.RESET_PASSWORD) {
        OtpResponse response =
            await apiService.userResetEmailVerify(email!, otp.toString());

        if (response.error) {
          if (response.message != null) {
            if (response.message!.contains("OTP has expired")) {
              resetTimer();
              _message = "Kode OTP telah kadaluarsa.";
              _isRequestOtp = true;
              notifyListeners();
            } else {
              _message = "Kode OTP yang kamu masukkan salah.";
              notifyListeners();
            }
          }
        } else {
          if (response.token != null) {
            _message = "Verifikasi email berhasil!";
              _isRequestOtp = false;
              resetTimer();
            notifyListeners();
            return response.token;
          }
        }
      } else if (type == OtpScreen.REGISTER) {
        LoginResponse response =
            await apiService.userEmailVerify(otp.toString());

        if (response.error) {
          _message = response.message!;          
          notifyListeners();
        } else {
          if(response.token != null){
            _message = "Verifikasi email berhasil!";
              _isRequestOtp = false;
              resetTimer();
            notifyListeners();
            return response.token;
          }else{
            _message = ApiService.SOMETHING_WAS_WRONG_SERVER;
            notifyListeners();
          }
        }
      }
      
    }
  }

  void resetTimer() {
    _secondsRemaining = 300;
    _timer?.cancel();
    notifyListeners();
  }

  void startCountdown() {
    _message = null;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        timer.cancel();
        notifyListeners();
      }
    });
  }

}
