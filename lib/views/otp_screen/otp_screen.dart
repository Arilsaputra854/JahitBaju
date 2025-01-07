import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/service/remote/response/login_response.dart';
import 'package:jahit_baju/views/home_screen/home_screen.dart';
import 'package:jahit_baju/views/login/login_screen.dart';
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

  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!init) {
      precacheImage(AssetImage("assets/background/bg.png"), context);
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
                width: deviceWidth * 0.8,
                height: deviceHeight * 0.8,
                child: SingleChildScrollView(child: _otpWidget(),),
              ),
            ))
      ],
    );
  }

  _otpWidget() {
    return Container(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Kode OTP",
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            "Kami telah kirim kode ke ${widget.email} kamu.\njika tidak ada, cek juga folder SPAM.",
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: Colors.white),
          ),
          const SizedBox(
            height: 20,
          ),
          OtpTextField(
            numberOfFields: 4,
            fieldWidth: deviceWidth* 0.15,
            showFieldAsBox: true,
            fillColor: Colors.white,
            focusedBorderColor: Color(0xFFBB5E44),
            filled: true,
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                            var response = await apiService.userRequestOtp();
                            Fluttertoast.showToast(msg: "${response.message!}");
                            if (response.toString().isNotEmpty) {
                              setState(() {
                                requestOTP = false;
                              });
                            
                              
                            } else {
                              Fluttertoast.showToast(msg: response.message!);
                            }

                          }
                        : () async {
                            LoginResponse response = await apiService
                                .userEmailVerify(currentOtp.toString());

                                if(response.error){

                                   Fluttertoast.showToast(msg: response.message!);
                                }else{

                            Fluttertoast.showToast(
                                msg: "Verifikasi email berhasil!");
                                goToHomeScreen();
                                }
                          },
                    child: Text(
                      requestOTP ? "Minta Kode" : "Aktivasi",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  goToResetPasswordScreen() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ResetPassword()));
  }
  void goToHomeScreen() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (Route<dynamic> route) => false);
  }
  
  countdown() {
    return Center(
            child: Text(
              "00:00",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: Colors.white),
            ),
          );
  }
}
