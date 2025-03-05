import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/register_view_model.dart';
import 'package:jahit_baju/views/otp_screen/otp_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../term_condition_screen/term_condition_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  var formKey = GlobalKey<FormState>();

  bool init = false;

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


    return Consumer<RegisterViewModel>(builder: (context, viewmodel, child) { 

      if(viewmodel.message != null){
        Fluttertoast.showToast(msg: viewmodel.message!);
      }
      return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child:Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 1.3,
                child: Container(
                  width: double.infinity,
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
                      builder: (context, viewmodel, child) {
                    return Center(
                      child: SizedBox(
                        width: 300.w,
                        child: registerForm(viewmodel),
                      ),
                    );
                  }),
                ),
              ),
              if (viewmodel.loading)
                loadingWidget()
            ],
          ),
    );});
  }

  registerForm(RegisterViewModel viewmodel){
    return Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "BUAT AKUN",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    height: 20,
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
                    onChanged: viewmodel.setName,
                    decoration: standartInputDecoration("Nama Lengkap"),
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
                    keyboardType: TextInputType.number,
                    onChanged: viewmodel.setPhoneNumber,
                    decoration: standartInputDecoration("No Telepon"),
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
                  TextFormField(

                  style: TextStyle(
                      fontSize: 14.sp,),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Kolom ini tidak boleh kosong!";
                      }
                      return null;
                    },
                    onChanged: viewmodel.setConfirmPassword,
                    obscureText: !viewmodel.hidePassword,
                    decoration: inputPasswordDecoration(viewmodel),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                              side: BorderSide(
                                color: Colors
                                    .white, // Ganti dengan warna outline yang diinginkan
                                width: 2.0, // Lebar outline
                              ),
                              value: viewmodel.agreeTerm,
                              onChanged: (value) {
                                viewmodel.setAgreeTerm(value);
                              }),
                          Expanded(
                              child: RichText(
                                  text: TextSpan(children: [
                            TextSpan(
                                text: "By signing up, you‘re agree to our ",
                                style: TextStyle(
                                    fontSize: 12.sp, color: Colors.white),
                                children: [
                                  TextSpan(
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          decoration: TextDecoration.underline,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          goToTermAndConditionScreen();
                                        },
                                      text:
                                          "Term and Condition and Privacy Policy")
                                ]),
                          ])))
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                backgroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey),
                            onPressed: viewmodel.agreeTerm
                                ? () async {
                                    if (formKey.currentState!.validate()) {
                                      FocusScope.of(context).unfocus();
                                      await viewmodel.register();
                                      if (viewmodel.message != null) {
                                        if (viewmodel.message ==
                                            "Buat akun berhasil!") {
                                          Navigator.pop(context);
                                        }
                                        Fluttertoast.showToast(
                                            msg: viewmodel.message.toString());
                                      }
                                    }
                                  }
                                : null,
                            child:  Text(
                              "Register",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16.sp),
                            )),
                      ),
                    ],
                  ),
                ]),
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

  inputPasswordDecoration(RegisterViewModel viewmodel){
    return InputDecoration(
        errorStyle: TextStyle(color: Colors.white),
        fillColor: Colors.white,
        filled: true,
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

  void goToTermAndConditionScreen() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => TermConditionScreen()));
  }
}
