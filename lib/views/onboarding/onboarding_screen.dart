import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:jahit_baju/views/login/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<ContentConfig> listContentConfig = [];

  @override
  void initState() {
    super.initState();

    listContentConfig.add(
      const ContentConfig(
        backgroundImage: "assets/onboarding/onboarding_1.png",
        backgroundFilterColor: Colors.transparent,

        backgroundFilterOpacity: 0.0
      ),
    );
    listContentConfig.add(
      const ContentConfig(
        backgroundImage: "assets/onboarding/onboarding_2.png",
        backgroundFilterColor: Colors.transparent,
        
        backgroundFilterOpacity: 0.0
      ),
    );
    listContentConfig.add(
      const ContentConfig(
        backgroundImage: "assets/onboarding/onboarding_3.png",
        backgroundFilterColor: Colors.transparent,
        
        backgroundFilterOpacity: 0.0
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: IntroSlider(
      key: UniqueKey(),
      listContentConfig: listContentConfig,
      onDonePress: () => goToLoginPage(),
      onSkipPress: () =>  goToLoginPage(),
    ),
    );
  }


  goToLoginPage() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

}