import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/service/remote/response/product_response.dart';
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

ApiService apiService = ApiService();

Future<Product?> getProductById(productId) async {
    ProductResponse response = await apiService.productsGetById(productId);
    if (response.error) {
      Fluttertoast.showToast(msg: response.message ?? "Terjadi Kesalahan");
      return null;
    } else {
      return response.product!;
    }
  }

Widget svgViewer(String svg){  
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
          
    return WebViewWidget(      
                  controller: controller,
                  gestureRecognizers: Set(),
                );
}

// Future<void> checkConnection(BuildContext context) async {
//   // Cek status koneksi internet
//   final connectivityResult = await Connectivity().checkConnectivity();

//   if (connectivityResult == ConnectivityResult.none) {
//     // Jika tidak ada koneksi internet
//     showSnackBar(context, "Kamu sedang offline!", isError: true);
//     return;
//   }

//   // Jika ada koneksi, cek status server
//   try {
//     final response = await http.get(Uri.parse(ApiService().baseUrl)).timeout(Duration(seconds: 5));

//     if (response.statusCode >= 200 && response.statusCode < 300) {
//     showSnackBar(context, "Terjadi kesalahan pada server. ${response.statusCode}", isError: true);
//     }
//   } catch (e) {
//     // Timeout atau error lainnya
//     showSnackBar(context, "Terjadi kesalahan pada server.", isError: true);
//   }
// }

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