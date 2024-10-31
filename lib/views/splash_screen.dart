import 'package:flutter/material.dart';
import 'package:jahit_baju/views/onboarding/onboarding_screen.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  var init = true;

  @override
  void didChangeDependencies() {
    if(init){
      init = false;
      precacheImage(AssetImage("assets/logo/jahit_baju_logo.png"), context);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;

    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => OnboardingScreen()));
    });

    return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
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
        child: SizedBox(
            width: 250,
            height: 250,
            child: Image.asset("assets/logo/jahit_baju_logo.png")),
      ),
    ));
  }
}