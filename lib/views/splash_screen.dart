import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/views/home_screen/fragment/home_page.dart';
import 'package:jahit_baju/views/home_screen/home_screen.dart';
import 'package:jahit_baju/views/login/login_screen.dart';
import 'package:jahit_baju/views/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var init = true;
  String? version;

  @override
  void didChangeDependencies() {
    if (init) {
      init = false;
      precacheImage(
          const AssetImage("assets/logo/jahit_baju_logo.png"), context);
    }
    super.didChangeDependencies();
  }

  final TokenStorage _tokenStorage = TokenStorage();

  @override
  void initState() {
    readUserToken();
    getAppVersion();
    super.initState();
  }

  getAppVersion() {
    version = "1.0.4";
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0xFF57AFF9),
              Color(0xFF8BE0E5),
              Color(0xFFDFCFAF),
              Color(0xFFFDCA8A),
              Color(0xFFFEAEA9),
            ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    width: 200.w,
                    height: 200.w,
                    child: Image.asset("assets/logo/jahit_baju_logo.png")),
                    SizedBox(height: 50.h,),
                Text(
                  "v${version ?? "0.0.0"}",
                  style: TextStyle(fontSize: 12.sp),
                )
              ],
            )));
  }

  void readUserToken() async {
    String? token = await _tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    if (token != null && token.isNotEmpty && token != "") {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const HomeScreen(),
                settings: RouteSettings(name: "Home")));
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()));
      });
    }
  }
}
