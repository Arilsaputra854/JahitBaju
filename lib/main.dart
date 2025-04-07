import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting("id_ID");
  await Firebase.initializeApp();

  // Setup Firebase Crashlytics
  FlutterError.onError = (FlutterErrorDetails errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final navKey = new GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => ApiService(context)),
        Provider(create: (context) => Repository(context.read<ApiService>())),

        ChangeNotifierProvider(create: (context) => CartViewModel(context.read<ApiService>())),
        ChangeNotifierProvider(create: (context) => ForgotPasswordViewModel()),
        ChangeNotifierProvider(create: (context) => HomeViewModel(context.read<Repository>(), context.read<ApiService>())),
        ChangeNotifierProvider(create: (context) => PaymentViewModel(context.read<ApiService>())),
        ChangeNotifierProvider(create: (context) => RegisterViewModel(context.read<ApiService>())),
        ChangeNotifierProvider(create: (context) => ResetPasswordViewModel(context.read<ApiService>())),
        ChangeNotifierProvider(create: (context) => SearchViewModel(context.read<Repository>())),
        ChangeNotifierProvider(create: (context) => ShippingViewModel(context.read<ApiService>())),
        ChangeNotifierProvider(create: (context) => HomeScreenViewModel(context.read<ApiService>())),
        ChangeNotifierProvider(create: (context) => DesignerViewModel(context.read<ApiService>())),
        ChangeNotifierProvider(create: (context) => LoginViewModel(context.read<ApiService>())),
        ChangeNotifierProvider(create: (context) => OtpScreenViewModel(context.read<ApiService>())),
        ChangeNotifierProvider(create: (context) => LookViewModel(context.read<ApiService>())),
        ChangeNotifierProvider(create: (context) => AddressViewModel(context.read<ApiService>())),
        ChangeNotifierProvider(create: (context) => FavoriteViewModel(context.read<ApiService>())),
        ChangeNotifierProvider(create: (context) => ProductViewModel(context.read<ApiService>())),
        ChangeNotifierProvider(create: (context) => CustomProductViewModel(context.read<ApiService>())),
        ChangeNotifierProvider(create: (context) => ProfileViewModel(context.read<ApiService>())),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 640),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(key: GlobalKey(), // Menambahkan key
  navigatorKey: MyApp.navKey, 
            localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [
      Locale('id', 'ID'),
    ],


            debugShowCheckedModeBanner: false,
            title: 'Jahit Baju Apps',
            theme: ThemeData(
              fontFamily: "Poppins",
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFBB5E44)),
              useMaterial3: true,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
