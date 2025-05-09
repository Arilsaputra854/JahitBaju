import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/login_view_model.dart';
import 'package:jahit_baju/views/forgot_password/forgot_password.dart';
import 'package:jahit_baju/views/home_screen/home_screen.dart';
import 'package:jahit_baju/views/otp_screen/otp_screen.dart';
import 'package:jahit_baju/views/register/register_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var formKey = GlobalKey<FormState>();  

  bool init = false;


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

    return Consumer<LoginViewModel>(builder: (context, viewmodel, child) {
      return GestureDetector(child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Transform.scale(
              scale: 1.3,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  image: DecorationImage(
                    image: AssetImage("assets/background/bg.png"),
                    fit: BoxFit.cover,
                    opacity: 0.6,
                  ),
                ),
              )),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Container(
                height: 400.w,
                width: 320.w,
                child:loginForm(viewmodel)),
              )
            ),
            if (viewmodel.loading)
              loadingWidget()
          ],
        ),onTap: (){
          FocusScope.of(context).unfocus(); 
        },);});
  }

  loginForm(LoginViewModel viewmodel) {
    return Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "MASUK",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  style: TextStyle(
                      fontSize: 14.sp,),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Kolom ini tidak boleh kosong!";
                    }
                    return null;
                  },
                  onChanged: viewmodel.setEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: inputEmailDecoration(),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  style: TextStyle(
                      fontSize: 14.sp,),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Kolom ini tidak boleh kosong!";
                    }
                    return null;
                  },
                  onChanged: viewmodel.setPassword,
                  obscureText: !viewmodel.hidePassword,
                  decoration: inputPasswordDecoration(viewmodel),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => goToForgotPassword(),
                        text: "Lupa password?",
                        style: TextStyle(fontSize: 12.sp, color: Colors.white),
                      ),
                    ]))
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Column(
                  children: [
                    SizedBox(
                      width: 320.w,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              backgroundColor: Colors.white),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              FocusScope.of(context).unfocus();
                              login(viewmodel);
                            }
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14.sp),
                          )),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => goToRegisterScreen(),
                        text: "Ga punya akun? Buat sekarang!",
                        style: TextStyle(fontSize: 12.sp, color: Colors.white),
                      ),
                    ]))
                  ],
                ),
              ],
            ),
          ));
  }

  inputEmailDecoration() {
    return const InputDecoration(
        fillColor: Colors.white,
        filled: true,
        errorStyle: TextStyle(color: Colors.white),
        hintText: "janedoe@gmail.com",
        hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))));
  }

  inputPasswordDecoration(LoginViewModel viewmodel) {
    return InputDecoration(
        fillColor: Colors.white,
        filled: true,
        errorStyle: TextStyle(color: Colors.white),
        hintText: "********",
        suffixIcon: IconButton(
            onPressed: () {
              viewmodel.setHidePassword(!viewmodel.hidePassword);
            },
            icon: Icon(
                viewmodel.hidePassword ? Icons.visibility : Icons.visibility_off)),
        hintStyle:
            const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))));
  }

  goToForgotPassword() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
  }

  goToRegisterScreen() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RegisterScreen()));
  }

  void goToHomeScreen() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (Route<dynamic> route) => false);
  }

  Future<void> login(LoginViewModel viewmodel) async {
    
    await viewmodel.login().then((isSuccess) async {
      if (viewmodel.message != null) {
        Fluttertoast.showToast(msg: viewmodel.message.toString());
      }
      if (isSuccess) {
        await viewmodel.emailVerified().then((isVerified) {
          if (isVerified) {
            Fluttertoast.showToast(msg: "Login berhasil!");

            goToHomeScreen();
          } else {
            goTogoToOtpPage(viewmodel.email);
            Fluttertoast.showToast(msg: "Email belum terverifikasi!");
          }
        });
      }
    });
  }

  void goTogoToOtpPage(String? email) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OtpScreen(email!, OtpScreen.REGISTER)));
  }
}
