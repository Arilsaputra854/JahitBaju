import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/helper/viewmodels/login_view_model.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  var deviceWidth, deviceHeight;

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(create: (context) => LoginViewModel()
    ,child: Stack(
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
          body: Consumer<LoginViewModel>(builder: (context, viewModel, child) {
            return Center(
            child: SizedBox(
              width: deviceWidth * 0.8,
              height: deviceHeight * 0.5,
              child: loginForm(),
            ),
          );
          }
          
        ),
    )],
    ));
  }

  loginForm() {
    return Consumer<LoginViewModel>(builder: (context, viewModel, child) {
      return Container(
        padding: const EdgeInsets.all(16),
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
            TextField(
              onChanged: viewModel.setEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: inputEmailDecoration(),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              onChanged: viewModel.setPassword,
              obscureText: !_isPasswordVisible,
              decoration: inputPasswordDecoration(),
            ),
            const SizedBox(
              height: 10,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Lupa password?",
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
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
                    viewModel.Login();
                    if(viewModel.errorMsg != null){
                      Fluttertoast.showToast(msg: viewModel.errorMsg.toString());
                    }
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  )),
            )
          ],
        ),
      );
    });
  }

  inputEmailDecoration() {
    return const InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: "janedoe@gmail.com",
        hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))));
  }

  inputPasswordDecoration() {
    return InputDecoration(
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
}
