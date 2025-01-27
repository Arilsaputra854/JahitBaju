import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jahit_baju/data/repository/repository.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/viewmodels/cart_view_model.dart';
import 'package:jahit_baju/viewmodels/forgot_password_view_model.dart';
import 'package:jahit_baju/viewmodels/home_screen_view_model.dart';
import 'package:jahit_baju/viewmodels/home_view_model.dart';
import 'package:jahit_baju/viewmodels/payment_view_model.dart';
import 'package:jahit_baju/viewmodels/register_view_model.dart';
import 'package:jahit_baju/viewmodels/reset_password_view_model.dart';
import 'package:jahit_baju/viewmodels/search_view_model.dart';
import 'package:jahit_baju/viewmodels/shipping_view_model.dart';
import 'package:jahit_baju/views/home_screen/home_screen.dart';
import 'package:jahit_baju/views/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting("id_ID");
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => CartViewModel(ApiService(context))),
    ChangeNotifierProvider(create: (context) => ForgotPasswordViewModel()),
    ChangeNotifierProvider(create: (context) => HomeViewModel(Repository(ApiService(context)))),
    ChangeNotifierProvider(create: (context) => PaymentViewModel(ApiService(context))),
    ChangeNotifierProvider(create: (context) => RegisterViewModel(ApiService(context))),
    ChangeNotifierProvider(create: (context) => ResetPasswordViewModel(ApiService(context))),
    ChangeNotifierProvider(create: (context) => SearchViewModel(Repository(ApiService(context)))),
    ChangeNotifierProvider(create: (context) => ShippingViewModel(ApiService(context))),
    ChangeNotifierProvider(create: (context) => HomeScreenViewModel(ApiService(context))),
  ],
  child: const MyApp(),));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jahit Baju Apps',
      theme: ThemeData(
        fontFamily: "Poppins",
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFBB5E44)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
