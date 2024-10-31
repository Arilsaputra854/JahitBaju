import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/helper/viewmodels/login_view_model.dart';
import 'package:jahit_baju/helper/viewmodels/register_view_model.dart';
import 'package:jahit_baju/views/forgot_password/forgot_password.dart';
import 'package:jahit_baju/views/register/register_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  var deviceWidth, deviceHeight;
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
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
        create: (context) => LoginViewModel(),
        child: Stack(
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
              backgroundColor: Colors.transparent,
              body: Consumer<LoginViewModel>(
                  builder: (context, viewModel, child) {
                return Center(
                  child: SizedBox(
                    width: deviceWidth * 0.8,
                    height: deviceHeight * 0.5,
                    child: loginForm(),
                  ),
                );
              }),
            )
          ],
        ));
  }

  loginForm() {
    return Consumer<LoginViewModel>(builder: (context, viewModel, child) {
      return Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "MASUK",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Kolom ini tidak boleh kosong!";
                    }
                    return null;
                  },
                  onChanged: viewModel.setEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: inputEmailDecoration(),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return "Kolom ini tidak boleh kosong!";
                    }
                    return  null;
                  },
                  onChanged: viewModel.setPassword,
                  obscureText: !_isPasswordVisible,
                  decoration: inputPasswordDecoration(),
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
                        style: TextStyle(fontSize: 12, color: Colors.white),
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
                      width: deviceWidth,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              backgroundColor: Colors.white),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              viewModel.Login();
                              if (viewModel.errorMsg != null) {
                                Fluttertoast.showToast(
                                    msg: viewModel.errorMsg.toString());
                              }
                            }
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
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
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ]))
                  ],
                ),
              ],
            ),
          ));
    });
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

  inputPasswordDecoration() {
    return InputDecoration(
        fillColor: Colors.white,
        filled: true,
        errorStyle: TextStyle(color: Colors.white),
        hintText: "********",
        suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off)),
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
}
