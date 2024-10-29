import 'package:flutter/material.dart';
import 'package:jahit_baju/ui/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jahit Baju Apps',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFBB5E44)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
