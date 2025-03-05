import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/login_response.dart';
import 'package:jahit_baju/data/source/remote/response/otp_response.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/home_view_model.dart';
import 'package:jahit_baju/viewmodels/otp_screen_view_model.dart';
import 'package:jahit_baju/views/home_screen/home_screen.dart';
import 'package:jahit_baju/views/reset_password/reset_password.dart';
import 'package:provider/provider.dart';

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
  bool init = false;

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

    return Consumer<OtpScreenViewModel>(builder: (context, viewModel, child) {
      viewModel.setEmail(widget.email);

      if(viewModel.message != null){
        Fluttertoast.showToast(msg: viewModel.message!);
      }
      return Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: 1.3,
            child: Container(
              width: 340.w,
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
                    child: _otpWidget(viewModel),
                  ),
                ),
              )),
          if (viewModel.loading) loadingWidget()
        ],
      );
    });
  }

  _otpWidget(OtpScreenViewModel viewmodel) {
    return Container(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kode OTP",
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white),
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
            fieldWidth: 50.w,
            showFieldAsBox: true,
            fillColor: Colors.white,
            focusedBorderColor: const Color(0xFFBB5E44),
            filled: true,
            textStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            onSubmit: (value) async {
              viewmodel.setOtp(int.parse(value));
            },
          ),
          const SizedBox(
            height: 15,
          ),
          countdown(viewmodel),
          const SizedBox(
            height: 20,
          ),
          Column(
            children: [
              SizedBox(
                width: 340.w,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        backgroundColor: Colors.white),
                    onPressed: viewmodel.isRequestOtp
                        ? () async {
                            await viewmodel.sendOtpVerification(widget.type);
                          }
                        : () async {
                            String? token =  await viewmodel.verifyOtpVerification(widget.type);                            
                            if(token != null){
                              if(widget.type == OtpScreen.REGISTER){
                                goToLoginScreen(context);                                
                              }else{
                                goToResetPasswordScreen(token);
                              }
                            }
                          },
                    child: Text(
                      viewmodel.isRequestOtp ? "Minta Kode" : "Aktivasi",
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

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  countdown(OtpScreenViewModel viewmodel) {
    return Center(
      child: Text(
        formatTime(viewmodel.secondsRemaining),
        style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
            color: Colors.white),
      ),
    );
  }
}
