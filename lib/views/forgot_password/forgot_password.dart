import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/helper/viewmodels/forgot_password_view_model.dart';
import 'package:jahit_baju/views/register/register_screen.dart';
import 'package:jahit_baju/views/otp_screen/otp_screen.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
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
        create: (context) => ForgotPasswordViewModel(),
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
            Scaffold(appBar: AppBar(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
              ),
              backgroundColor: Colors.transparent,
              body: Consumer<ForgotPasswordViewModel>(
                  builder: (context, viewModel, child) {
                return Center(
                  child: SizedBox(
                    width: deviceWidth * 0.8,
                    height: deviceHeight * 0.5,
                    child: forgotPasswordForm(),
                  ),
                );
              }),
            )
          ],
        ));
  }

  forgotPasswordForm() {
    return Consumer<ForgotPasswordViewModel>(builder: (context, viewModel, child) {
      return Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "LUPA PASSWORD?",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),

                const Text(
                  "Tenang, kami bantu reset.",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
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
                  onChanged: viewModel.setEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: inputEmailDecoration(),
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
                              viewModel.resetPassword();
                              if (viewModel.errorMsg != null) {
                                Fluttertoast.showToast(
                                    msg: viewModel.errorMsg.toString());
                              }else{
                                goToOtpPage(viewModel.email);
                              }
                            }
                          },
                          child: const Text(
                            "Kirim Kode",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          )),
                    ),
                    
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

  goToOtpPage(String? email) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => OtpScreen(email!,OtpScreen.RESET_PASSWORD)));
  }
}
