import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jahit_baju/data/repository/repository.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/viewmodels/address_view_model.dart';
import 'package:jahit_baju/viewmodels/cart_view_model.dart';
import 'package:jahit_baju/viewmodels/custom_product_view_model.dart';
import 'package:jahit_baju/viewmodels/designer_view_model.dart';
import 'package:jahit_baju/viewmodels/favorite_view_model.dart';
import 'package:jahit_baju/viewmodels/forgot_password_view_model.dart';
import 'package:jahit_baju/viewmodels/home_screen_view_model.dart';
import 'package:jahit_baju/viewmodels/home_view_model.dart';
import 'package:jahit_baju/viewmodels/login_view_model.dart';
import 'package:jahit_baju/viewmodels/look_view_model.dart';
import 'package:jahit_baju/viewmodels/otp_screen_view_model.dart';
import 'package:jahit_baju/viewmodels/payment_view_model.dart';
import 'package:jahit_baju/viewmodels/product_view_model.dart';
import 'package:jahit_baju/viewmodels/profile_view_model.dart';
import 'package:jahit_baju/viewmodels/register_view_model.dart';
import 'package:jahit_baju/viewmodels/reset_password_view_model.dart';
import 'package:jahit_baju/viewmodels/search_view_model.dart';
import 'package:jahit_baju/viewmodels/shipping_view_model.dart';
import 'package:jahit_baju/views/splash_screen.dart';
import 'package:provider/provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting("id_ID");
  await Firebase.initializeApp();
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartViewModel(ApiService(context))),
        ChangeNotifierProvider(create: (context) => ForgotPasswordViewModel()),
        ChangeNotifierProvider(create: (context) => HomeViewModel(Repository(ApiService(context)),ApiService(context))),
        ChangeNotifierProvider(create: (context) => PaymentViewModel(ApiService(context))),
        ChangeNotifierProvider(create: (context) => RegisterViewModel(ApiService(context))),
        ChangeNotifierProvider(create: (context) => ResetPasswordViewModel(ApiService(context))),
        ChangeNotifierProvider(create: (context) => SearchViewModel(Repository(ApiService(context)))),
        ChangeNotifierProvider(create: (context) => ShippingViewModel(ApiService(context))),
        ChangeNotifierProvider(create: (context) => HomeScreenViewModel(ApiService(context))),
        ChangeNotifierProvider(create: (context) => DesignerViewModel(ApiService(context))),
        ChangeNotifierProvider(create: (context) => LoginViewModel(ApiService(context))),
        ChangeNotifierProvider(create: (context) => OtpScreenViewModel(ApiService(context))),
        ChangeNotifierProvider(create: (context) => LookViewModel(ApiService(context))),
        ChangeNotifierProvider(create: (context) => AddressViewModel(ApiService(context))),
        ChangeNotifierProvider(create: (context) => FavoriteViewModel(ApiService(context))),
        ChangeNotifierProvider(create: (context) => ProductViewModel(ApiService(context))),
        ChangeNotifierProvider(create: (context) => CustomProductViewModel(ApiService(context))),
        ChangeNotifierProvider(create: (context) => ProfileViewModel(ApiService(context))),
      ],
      child: ScreenUtilInit(
        designSize: Size(360, 640),
        builder: (context, child) {
          return const MyApp();
        },
      ),
    ),
  );
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
