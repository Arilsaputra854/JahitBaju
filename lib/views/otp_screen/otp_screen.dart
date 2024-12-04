import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
                height: deviceHeight * 0.5,
                child: forgotPasswordForm(),
              ),
            ))
      ],
    );
  }

  forgotPasswordForm() {
    return Container(
      padding: const EdgeInsets.all(16),
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
            height: 30,
          ),
          OtpTextField(
            numberOfFields: 4,
            fieldWidth: 60,
            margin: EdgeInsets.symmetric(horizontal: 10),
            showFieldAsBox: true,
            fillColor: Colors.white,
            focusedBorderColor: Color(0xFFBB5E44),
            filled: true,
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            onSubmit: (value) {
              setState(() {
                if (int.parse(value) == 0000) {
                  isOtpValid = true;
                } else {
                  isOtpValid = false;
                }
              });
            },
          ),
          const SizedBox(
            height: 30,
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
                    onPressed: () {
                      if (!isOtpValid) {
                        Fluttertoast.showToast(
                            msg: "OTP yang kamu masukkan tidak valid!");
                      } else {
                        if (widget.type == OtpScreen.REGISTER) {
                          Fluttertoast.showToast(msg: "Account Verified!");
                          Future.delayed(Duration(seconds: 2), () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                                  (route) => false,
                            );
                          });
                        } else {
                          goToResetPasswordScreen();
                        }
                      }
                    },
                    child: const Text(
                      "Kirim Kode",
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
}
