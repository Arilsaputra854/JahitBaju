import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:jahit_baju/service/remote/api_service.dart';

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


Future<void> checkConnection(BuildContext context) async {
  // Cek status koneksi internet
  final connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.none) {
    // Jika tidak ada koneksi internet
    showSnackBar(context, "Kamu sedang offline!", isError: true);
    return;
  }

  // Jika ada koneksi, cek status server
  try {
    final response = await http.get(Uri.parse(ApiService().baseUrl)).timeout(Duration(seconds: 5));

    if (response.statusCode >= 200 && response.statusCode < 300) {
    showSnackBar(context, "Terjadi kesalahan pada server. ${response.statusCode}", isError: true);
    }
  } catch (e) {
    // Timeout atau error lainnya
    showSnackBar(context, "Terjadi kesalahan pada server.", isError: true);
  }
}

// Fungsi untuk menampilkan SnackBar
void showSnackBar(BuildContext context, String message, {required bool isError}) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: isError ? Colors.red : Colors.green,
    duration: Duration(seconds: 3),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}