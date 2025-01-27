import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/product_response.dart';
import 'package:jahit_baju/data/source/remote/response/survei_response.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/views/login/login_screen.dart';
import 'package:logger/web.dart';
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


Future<bool> sentSurveiData(
    String sourceAnswer, String field1answer, String field2answer,ApiService apiService) async {    

  SurveiResponse response =
      await apiService.sendSurveiData(sourceAnswer, field1answer, field2answer);
  if (response.error) {
    return false;
  } else {
    return true;
  }
}


  Future<bool> loadAccessCustom(ApiService apiService) async {
    SurveiResponse response =
        await apiService.getSurveiData();
    if (response.error) {
      return false;
    } else {
      return true;
    }
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

void showDialogSession(BuildContext context){
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sesi Anda Telah Habis'),
          content: Text('Silakan login kembali untuk melanjutkan.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                logoutUser(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
}



  logoutUser(BuildContext context) async {
    TokenStorage tokenStorage = TokenStorage();
    await tokenStorage.deleteToken(TokenStorage.TOKEN_KEY);
    Fluttertoast.showToast(msg: "Logout berhasil");
    goToLoginScreen(context);
  }


  void goToLoginScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false);
  }


Future<bool> checkInternetConnection() async {  
  try {
    final result = await InternetAddress.lookup('example.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}
