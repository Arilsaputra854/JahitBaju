import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/helper/viewmodels/register_view_model.dart';
import 'package:jahit_baju/views/otp_screen/otp_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isPasswordVisible = false;
  var deviceWidth, deviceHeight;
  var formKey = GlobalKey<FormState>();

  bool init = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLoading = false;
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
        create: (context) => RegisterViewModel(),
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
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
              ),
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                child: Consumer<RegisterViewModel>(
                  builder: (context, viewModel, child) {
                return Center(
                  child: SizedBox(
                    width: deviceWidth * 0.8,
                    child: registerForm(),
                  ),
                );
              }),
            ),
              ),
            if (isLoading)
              LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.black, size: 50)
          ],
        ));
  }

  registerForm() {
    return Consumer<RegisterViewModel>(builder: (context, viewModel, child) {
      return Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "BUAT AKUN",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Kolom ini tidak boleh kosong!";
                      }
                      return null;
                    },
                    onChanged: viewModel.setName,
                    decoration: standartInputDecoration("Nama Lengkap"),
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
                    keyboardType: TextInputType.number,
                    onChanged: viewModel.setPhoneNumber,
                    decoration: standartInputDecoration("No Telepon"),
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Kolom ini tidak boleh kosong!";
                      }
                      return null;
                    },
                    onChanged: viewModel.setPassword,
                    obscureText: !_isPasswordVisible,
                    decoration: inputPasswordDecoration(),
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
                    onChanged: viewModel.setConfirmPassword,
                    obscureText: !_isPasswordVisible,
                    decoration: inputPasswordDecoration(),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: [
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: "By signing up, you‘re agree to our ",
                            style: TextStyle(fontSize: 12, color: Colors.white),
                            children: [
                              TextSpan(
                                  style: TextStyle(
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Fluttertoast.showToast(msg: "msg");
                                    },
                                  text: "Term and Condition and Privacy Policy")
                            ]),
                      ])),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        width: deviceWidth,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                backgroundColor: Colors.white),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });

                                await viewModel.register();
                                if (viewModel.message != null) {
                                  if (viewModel.message == "Register Success!") {
                                    goToOtpPage(viewModel.email);
                                  }
                                  Fluttertoast.showToast(
                                      msg: viewModel.message.toString());
                                }

                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            )),
                      ),
                    ],
                  ),
                ]),
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

  standartInputDecoration(String hint) {
    return InputDecoration(
        errorStyle: TextStyle(color: Colors.white),
        fillColor: Colors.white,
        filled: true,
        hintText: hint,
        hintStyle:
            const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))));
  }

  inputPasswordDecoration() {
    return InputDecoration(
        errorStyle: TextStyle(color: Colors.white),
        fillColor: Colors.white,
        filled: true,
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

  void goToOtpPage(String? email) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => OtpScreen(email!, OtpScreen.REGISTER)));
  }
}
