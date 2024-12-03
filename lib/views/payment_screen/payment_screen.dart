import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/model/order.dart';
import 'package:jahit_baju/util/util.dart';

class PaymentScreen extends StatefulWidget {
  Order? order;
  PaymentScreen({required this.order, super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  var deviceWidth, deviceHeight;

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Payment"),
      ),
      body: Container(
        width: deviceWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo/jahit_baju_logo.png",
              width: deviceHeight * 0.3,
            ),
            SizedBox(
              height: 40,
            ),
            Text("Menunggu proses pembayaran",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(
              height: 5,
            ),
            Text("Id : ${widget.order?.id ?? ""}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            SizedBox(
              height: 10,
            ),
            Text("Total Harga : ${convertToRupiah(widget.order?.totalPrice)}"),
            SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: (){
                openXenditGateway();
              },
              child: Text(
                "Bayar Sekarang",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0)),
                backgroundColor: Colors.red, // Latar belakang merah
                padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 30), // Padding agar tombol lebih besar
              ),
            )
          ],
        ),
      ),
    );
  }
  
  void openXenditGateway() {
    
  }

}
