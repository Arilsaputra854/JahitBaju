import 'package:flutter/material.dart';
import 'package:jahit_baju/views/onboarding/onboarding_screen.dart';

import 'login/login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;

    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => OnboardingScreen()));
    });

    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Color(0xFF57AFF9),
              Color(0xFF8BE0E5),
              Color(0xFFDFCFAF),
              Color(0xFFFDCA8A),
              Color(0xFFFEAEA9),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft)
          ),
      child: Center(
        child: Container(
            width: 250,
            height: 250,
            child: Image.asset("assets/logo/jahit_baju_logo.png")),
      ),
    ));
  }
}
