import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/login_response.dart';
import 'package:jahit_baju/data/source/remote/response/otp_response.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/views/home_screen/home_screen.dart';
import 'package:jahit_baju/views/reset_password/reset_password.dart';

class OtpScreen extends StatefulWidget {
  static const REGISTER = 1;
  static const RESET_PASSWORD = 2;

  String email;
  int type;

  OtpScreen(this.email, this.type, {super.key});

  @override
  State<OtpScreen> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<OtpScreen> {
  var deviceWidth, deviceHeight;

  bool init = false;
  bool isOtpValid = false;
  bool requestOTP = true;

  int currentOtp = 0;

  late ApiService apiService;

  late Timer _timer;
  int _secondsRemaining = 300;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(context);
  }

  @override
  void didChangeDependencies() {
    if (!init) {
      precacheImage(const AssetImage("assets/background/bg.png"), context);
      init = true;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.scale(
          scale: 1.3,
          child: Container(
            width: deviceWidth,
            decoration: const BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                    image: AssetImage("assets/background/bg.png"),
                    fit: BoxFit.cover,
                    opacity: 0.6)),
          ),
        ),
        Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
            ),
            backgroundColor: Colors.transparent,
            body: Center(
              child: SizedBox(
                width: 300.w,
                height: 500.h,
                child: SingleChildScrollView(
                  child: _otpWidget(),
                ),
              ),
            )),
            if(loading) loadingWidget()
      ],
    );
  }

  _otpWidget() {
    return Container(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kode OTP",
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            "Kami telah kirim kode ke ${widget.email} kamu.\njika tidak ada, cek juga folder SPAM.",
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
                color: Colors.white),
          ),
          const SizedBox(
            height: 20,
          ),
          OtpTextField(
            numberOfFields: 4,
            fieldWidth: deviceWidth * 0.15,
            showFieldAsBox: true,
            fillColor: Colors.white,
            focusedBorderColor: const Color(0xFFBB5E44),
            filled: true,
            textStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            onSubmit: (value) async {
              currentOtp = int.parse(value);
            },
          ),
          const SizedBox(
            height: 15,
          ),
          countdown(),
          const SizedBox(
            height: 20,
          ),
          Column(
            children: [
              SizedBox(
                width: deviceWidth,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        backgroundColor: Colors.white),
                    onPressed: requestOTP
                        ? () async {
                          setState(() {
                            loading = true;
                          });
                            if (widget.type == OtpScreen.RESET_PASSWORD) {
                              var response = await apiService
                                  .userResetRequestOtp(widget.email);

                              if (response.error) {
                                if (response.message!.contains(
                                    "OTP is already valid and not expired. Please verify it.")) {
                                  Fluttertoast.showToast(
                                      msg:
                                          "Kode OTP masih valid. silakan cek email kamu.");

                                  setState(() {
                                    requestOTP = false;
                                  });

                                startCountdown();
                                }
                                if (response.message!
                                    .contains("User not found.")) {
                                  Fluttertoast.showToast(
                                      msg:
                                          "Email yang kamu masukkan tidak ditemukan.");

                                  setState(() {
                                    requestOTP = true;
                                  });
                                }
                                
                              } else {
                                if (response.message!.contains(
                                    "OTP has been successfully sent to your email.")) {
                                  Fluttertoast.showToast(
                                      msg: "Kode OTP berhasil dikirim.");
                                  setState(() {
                                    requestOTP = false;
                                  });
                                }
                                startCountdown();
                              }                              
                            } else if (widget.type == OtpScreen.REGISTER) {
                              OtpResponse response =
                                  await apiService.userRequestOtp();

                              if (response.error) {
                                if (response.message!
                                    .contains("User not found.")) {
                                  Fluttertoast.showToast(
                                      msg:
                                          "Email yang kamu masukkan tidak ditemukan.");

                                  setState(() {
                                    requestOTP = true;
                                  });
                                }
                                if (response.message!.contains(
                                    "OTP is already valid and not expired. Please verify it.")) {
                                  Fluttertoast.showToast(
                                      msg:
                                          "Kode OTP masih valid. silakan cek email kamu.");

                                  setState(() {
                                    requestOTP = false;
                                  });

                                startCountdown();
                                }
                              } else {
                                if (response.message!.contains(
                                    "OTP has been successfully sent to your email.")) {
                                  Fluttertoast.showToast(
                                      msg: "Kode OTP berhasil dikirim.");
                                  setState(() {
                                    requestOTP = false;
                                  });
                                }
                                startCountdown();
                              }
                            }
                            setState(() {
                            loading = false;
                          });
                          }
                        : () async {
                          setState(() {
                            loading = true;
                          });
                            if (widget.type == OtpScreen.RESET_PASSWORD) {
                              OtpResponse response =
                                  await apiService.userResetEmailVerify(
                                      widget.email, currentOtp.toString());

                              if (response.error) {
                                if (response.message != null) {
                                  if (response.message!
                                      .contains("OTP has expired")) {
                                    resetTimer();
                                    Fluttertoast.showToast(
                                        msg: "Kode OTP telah kadaluarsa.");
                                    setState(() {
                                      requestOTP = true;
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            "Kode OTP yang kamu masukkan salah.");
                                  }
                                }
                              } else {
                                if (response.token != null) {
                                  goToResetPasswordScreen(response.token!);
                                  Fluttertoast.showToast(
                                      msg: "Verifikasi email berhasil!");
                                }
                              }
                            } else if (widget.type == OtpScreen.REGISTER) {
                              LoginResponse response = await apiService
                                  .userEmailVerify(currentOtp.toString());

                              if (response.error) {
                                Fluttertoast.showToast(msg: response.message!);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Verifikasi email berhasil!");
                                goToHomeScreen();
                              }
                            }
                            setState(() {
                            loading = false;
                          });
                          },
                    child: Text(
                      requestOTP ? "Minta Kode" : "Aktivasi",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.sp),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  goToResetPasswordScreen(String token) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ResetPassword(token)));
  }

  void goToHomeScreen() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false);
  }

  void resetTimer() {
    setState(() {
      _secondsRemaining = 300;
    });
    _timer.cancel();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  countdown() {
    return Center(
      child: Text(
        formatTime(_secondsRemaining),
        style: TextStyle(
            fontSize: 14.sp, fontWeight: FontWeight.normal, color: Colors.white),
      ),
    );
  }
}
