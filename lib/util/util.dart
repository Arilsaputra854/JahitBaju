
import 'package:intl/intl.dart';


String convertToRupiah(dynamic value){
  String converted = "";

  final formatter = NumberFormat.currency(
  locale: 'id_ID', // Locale Indonesia
  symbol: 'Rp ',    // Simbol Rupiah
  decimalDigits: 0, // Tanpa desimal
);

  converted = formatter.format(value.toDouble());


  return converted;
}