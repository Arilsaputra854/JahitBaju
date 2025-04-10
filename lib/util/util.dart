import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:jahit_baju/data/cache/cache.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/source/local/db/db_helper.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/product_response.dart';
import 'package:jahit_baju/data/source/remote/response/survei_response.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/main.dart';
import 'package:jahit_baju/views/login/login_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/web.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter/webview_flutter.dart';

String convertToRupiah(dynamic value) {
  String converted = "";

  final formatter = NumberFormat.currency(
    locale: 'id_ID', // Locale Indonesia
    symbol: 'Rp ', // Simbol Rupiah
    decimalDigits: 0, // Tanpa desimal
  );

  converted = formatter.format(value.toDouble());
  return converted;
}


Future<Product?> getProductById(productId, ApiService apiService) async {
    ProductResponse response = await apiService.productsGetById(productId);
    if (response.error) {
      Fluttertoast.showToast(msg: response.message ?? "Terjadi Kesalahan");
      return null;
    } else {
      return response.product!;
    }
  }

Widget svgViewer(String svg){  

  Logger logger = Logger();
  WebViewController controller =WebViewController();  
  var htmlContent = '''
            <!DOCTYPE html>
            <html lang="en">
            <head>
              <meta name="viewport" content="width=device-width, initial-scale=0.7, maximum-scale=1, user-scalable=0">
              <style>
                body {
                  margin: 0;
                  padding: 0;
                  overflow: hidden; /* Disable scrolling */
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  height: 100vh;
                }
                svg {
                  max-width: 100%;
                  max-height: 100%;
                  display: block;
                  margin: auto;
                }
              </style>
            </head>
            <body>
              $svg
            </body>
            </html>
            ''';            
    controller.loadHtmlString(htmlContent);
          logger.d("SVG Loaded: $htmlContent");
    return WebViewWidget(      
                  controller: controller,
                  gestureRecognizers: Set(),
                );
}

String customFormatDate(DateTime date){
  return DateFormat('HH:mm, dd-MM-yyyy').format(date);
}

void showSnackBar(BuildContext context, String message, {required bool isError}) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: isError ? Colors.red : Colors.green,
    duration: Duration(seconds: 3),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
void showDialogSession(BuildContext context) {
  

              logoutUser(context); // Logout dan navigasi ke login screen
              Fluttertoast.showToast(msg: "Sesi anda telah habis, silakan login kembali");
  // showDialog(
  //   context: context,
  //   barrierDismissible: false,
  //   builder: (BuildContext dialogContext) { // Gunakan dialogContext agar tidak bentrok dengan context utama
  //     return AlertDialog(
  //       title: Text('Sesi Anda Telah Habis'),
  //       content: Text('Silakan login kembali untuk melanjutkan.'),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(dialogContext, rootNavigator: true).pop(); // Tutup dialog
  //           },
  //           child: Text('OK'),
  //         ),
  //       ],
  //     );
  //   },
  // );
}



  logoutUser(BuildContext context) async {    
    TokenStorage tokenStorage = TokenStorage();
    CacheHelper cache = CacheHelper();
    DatabaseHelper database = DatabaseHelper();

    await cache.removeBase64Map();
    await database.clearCache();
    
    await tokenStorage.deleteToken(TokenStorage.TOKEN_KEY);
    Fluttertoast.showToast(msg: "Logout berhasil");
    goToLoginScreen(context);
  }


  void goToLoginScreen(BuildContext context) {
    MyApp.navKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (route) => false,
  );
  }


Future<bool> checkInternetConnection() async {  
  try {
    final result = await InternetAddress.lookup('example.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

Widget loadingWidget({String? text}){
  return Container(
                color: const Color.fromARGB(92, 0, 0, 0),
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white, size: 50),
                      if(text != null) DefaultTextStyle(
    style: TextStyle(decoration: TextDecoration.none), 
    child : Text(text))],
                  )
                ),
              );
}

Widget itemCartShimmer() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 1, // Jumlah item shimmer
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 15,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 100,
                      height: 12,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
