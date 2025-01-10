import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/model/order.dart';
import 'package:jahit_baju/service/remote/response/order_response.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/home_view_model.dart';
import 'package:jahit_baju/viewmodels/payment_view_model.dart';
import 'package:jahit_baju/views/cart_screen/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../home_screen/home_screen.dart';

class PaymentScreen extends StatefulWidget {
  Order? order;
  PaymentScreen({required this.order, super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  var deviceWidth, deviceHeight;

  var isPaymentSuccess = false;

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(create:(context)=> PaymentViewModel(), child: Consumer<PaymentViewModel>(builder: (context,viewmodel, child){
      return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Payment"),
      ),
      body: isPaymentSuccess? paymentSuccess() : Container(
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
              height: 10,
            ),
            Text("Bayar sebelum ${customFormatDate(widget.order!.expiredDate)}"),
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
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: (){
                validatePaymentXenditGateway();
              },
              child: Text(
                "Sudah Bayar",
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
    }) );
  }
  

  Future<void> validatePaymentXenditGateway() async {
    ApiService apiService  =ApiService();
    OrderResponse response = await  apiService.orderGet();

    if(!response.error){
    late Order currentOrder;

      List<Order> orders = response.data;

      for (var order in orders) {
          if(order.id == widget.order!.id){
            currentOrder = order;
          }
      }

      if(currentOrder.orderStatus == Order.PROCESS){
        setState(() {
          isPaymentSuccess = true;
        });
      }
    }


  }

  Future<void> openXenditGateway() async {
    final url = Uri.parse(widget.order!.paymentUrl!);

    if(await canLaunchUrl(url)){
      await launchUrl(url,mode: LaunchMode.externalApplication).then((v){
        validatePaymentXenditGateway();
      });
      
    }else{
      Fluttertoast.showToast(msg: "Terjadi kesalahan, silakan coba lagi nanti.");
    }
  }
  
  Widget paymentSuccess() {

    Future.delayed(Duration(seconds: 2),() {
        Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (route) => false, // Menghapus semua aktivitas sebelumnya
      );
      context.read<HomeViewModel>().refresh();  
    },);

    return Center(
      child: Text("Pembayaran Berhasil!"),
    );
  }

}
