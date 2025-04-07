import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/login_response.dart';
import 'package:jahit_baju/data/source/remote/response/otp_response.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/views/otp_screen/otp_screen.dart';
import 'package:logger/logger.dart';

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
  Logger log = Logger();

  bool get loading => _loading;
  int? get otp => _otp;
  int get secondsRemaining => _secondsRemaining;
  String? get email => _email;
  bool get isRequestOtp => _isRequestOtp;
  String? get message => _message;

  final TokenStorage _tokenStorage = TokenStorage();
  void initialize() {
    _email = null;
    _isRequestOtp = true;
    _otp = null;
    _message = null;
    _secondsRemaining = 300;
    _timer?.cancel();
  }

  void setEmail(String email) {
  if (_email != email) { 
    _email = email;
    notifyListeners();
  }
}


  void setOtp(int otp) {
    _otp = otp;
    notifyListeners();
  }

  Future<void> sendOtpVerification(int type) async {
    _message = null;
    notifyListeners();
    if (email == null) return;

    _loading = true;
    notifyListeners(); // Notifikasi loading state

    try {
      OtpResponse response;
      if (type == OtpScreen.RESET_PASSWORD) {
        response = await apiService.userResetRequestOtp(email!);
      } else {
        response = await apiService.userRequestOtp();
      }

      if (response.error) {
        if (response.message!.contains("OTP has expired")) {
          resetTimer();
          _message = "Kode OTP telah kadaluarsa.";
          _isRequestOtp = true;
          notifyListeners();
        } else if (response.message!.contains("User not found.")) {
          _message = "Email tidak ditemukan.";
          _isRequestOtp = true;
          notifyListeners();
        } else if (response.message!.contains("OTP is already valid")) {
          _message = "Kode OTP masih valid.";
          _isRequestOtp = false;
          notifyListeners();
          startCountdown();
        } else {
          _message = "Tidak dapat mengirim kode OTP, ${response.message}";
          _isRequestOtp = true;
          notifyListeners();
        }
      } else {
        _message = "Kode OTP berhasil dikirim.";
        _isRequestOtp = false;
        startCountdown();
        notifyListeners();
      }
    } catch (e,stackTrace) {
        FirebaseCrashlytics.instance.recordError(e, stackTrace);
      _message = "Terjadi kesalahan, silakan coba lagi.";
    }

    _loading = false;
    notifyListeners(); // Notifikasi perubahan state setelah proses selesai
  }

  Future<dynamic> verifyOtpVerification(int type) async {
    _message = null;
    notifyListeners();
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
        OtpResponse response =
            await apiService.userEmailVerify(otp.toString());

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

            await _tokenStorage.saveToken(response.token!);
            log.d("Verify otp verification ${response.token}");
            return response.token;
          }
        }
      }
    }
  }

  void resetTimer() {
    _message = null;
    _secondsRemaining = 300;
    _timer?.cancel();
    notifyListeners();
  }

  void startCountdown() {
    resetTimer();
    _message = null;
    _message = null;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _isRequestOtp = true;
        _otp = null;
        timer.cancel();
        notifyListeners();
      }
    });
  }
}
