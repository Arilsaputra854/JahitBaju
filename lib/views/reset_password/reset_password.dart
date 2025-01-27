import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/viewmodels/reset_password_view_model.dart';
import 'package:jahit_baju/views/login/login_screen.dart';
import 'package:provider/provider.dart';

class ResetPassword extends StatefulWidget {
  final String token;
  const ResetPassword(this.token, {super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
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
        create: (context) => ResetPasswordViewModel(ApiService(context)),
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
              body: Consumer<ResetPasswordViewModel>(
                  builder: (context, viewModel, child) {
                return SingleChildScrollView(child: Center(
                  child: SizedBox(
                    width: deviceWidth * 0.8,
                    child: registerForm(),
                  ),
                ),);
              }),
            )
          ],
        ));
  }

  registerForm() {
    return Consumer<ResetPasswordViewModel>(
        builder: (context, viewModel, child) {
      return Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Ganti Password",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    height: 30,
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
                    decoration: inputPasswordDecoration("New password"),
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
                    decoration: inputPasswordDecoration("Confirm New password"),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: deviceWidth,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            backgroundColor: Colors.white),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            viewModel.changePassword(widget.token);
                            if (viewModel.errorMsg != null) {
                              Fluttertoast.showToast(
                                  msg: viewModel.errorMsg.toString());
                            }else{
                              Fluttertoast.showToast(msg:"Password berhasil diganti!");
                              goToLoginScreen();
                            }
                          }
                        },
                        child: const Text(
                          "Ganti Password",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        )),
                  ),
                ]),
          ));
    });
  }

  inputPasswordDecoration(String hint) {
    return InputDecoration(
        errorStyle: TextStyle(color: Colors.white),
        fillColor: Colors.white,
        filled: true,
        hintText: hint,
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

  goToLoginScreen(){
     Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,);
  }
}
