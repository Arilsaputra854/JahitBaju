import 'package:flutter/material.dart';
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

  @override
  void didChangeDependencies() {
    if (init) {
      init = false;
      precacheImage(const AssetImage("assets/logo/jahit_baju_logo.png"), context);
    }
    super.didChangeDependencies();
  }

  final TokenStorage _tokenStorage = TokenStorage();

  @override
  void initState() {
    readUserToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
        Color(0xFF57AFF9),
        Color(0xFF8BE0E5),
        Color(0xFFDFCFAF),
        Color(0xFFFDCA8A),
        Color(0xFFFEAEA9),
      ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
      child: Center(
        child: SizedBox(
            width: deviceWidth * 0.6,
            height: deviceWidth * 0.6,
            child: Image.asset("assets/logo/jahit_baju_logo.png")),
      ),
    ));
  }

  void readUserToken() async {
    String? token = await _tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    
    if (token != null && token.isNotEmpty && token != "") {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(          
            context, MaterialPageRoute(builder: (context) => const HomeScreen(), settings: RouteSettings(name: "Home")));
      });
      
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()));
      });
    }
  }
}
