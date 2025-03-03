import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image/image.dart' as img;
import 'package:jahit_baju/data/source/remote/response/feature_order_reaspones.dart';
import 'package:jahit_baju/data/source/remote/response/feature_response.dart';
import 'package:jahit_baju/data/source/remote/response/user_response.dart';
import 'package:logger/web.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/helper/app_color.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/data/model/order.dart';
import 'package:jahit_baju/data/source/remote/response/order_response.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/home_view_model.dart';
import 'package:jahit_baju/viewmodels/payment_view_model.dart';
import 'package:jahit_baju/views/cart_screen/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/model/feature_order.dart';
import '../home_screen/home_screen.dart';

class PaymentScreen extends StatefulWidget {
  Order? order;
  FeatureOrder? featureOrder;
  PaymentScreen({this.order, this.featureOrder, super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  var deviceWidth, deviceHeight;

  var isPaymentSuccess = false;
  Order? paidOrder;
  FeatureOrder? paidFeature;
  Logger log = Logger();

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
        create: (context) => PaymentViewModel(ApiService(context)),
        child: Consumer<PaymentViewModel>(builder: (context, viewmodel, child) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "Pembayaran",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            body: isPaymentSuccess
                ? paymentSuccess()
                : Container(
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
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14.sp)),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                            "Id : ${widget.order?.id ?? widget.featureOrder?.id ?? ""}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12.sp)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                            "Total Harga : ${convertToRupiah(widget.order?.totalPrice ?? widget.featureOrder?.price)}",
                            style: TextStyle(fontSize: 12.sp)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                            "Bayar sebelum ${customFormatDate(widget.order?.expiredDate ?? widget.featureOrder?.expiryDate ?? DateTime(2099))}",
                            style: TextStyle(fontSize: 12.sp)),
                        SizedBox(
                          height: 40,
                        ),
                        SizedBox(
                          width: deviceWidth * 0.5,
                          child: ElevatedButton(
                            onPressed: () {
                              openXenditGateway();
                            },
                            child: Text(
                              "Bayar Sekarang",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12.sp),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0)),
                              backgroundColor:
                                  Colors.red, // Latar belakang merah
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal:
                                      30), // Padding agar tombol lebih besar
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                            width: deviceWidth * 0.5,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (widget.order != null) {
                                  paidOrder =
                                      await validateOrderProductPaymentXenditGateway();
                                } else {
                                  paidFeature =
                                      await validateOrderFeaturePaymentXenditGateway();
                                      log.d("Paid Feature : ${paidFeature}");
                                }
                              },
                              child: Text(
                                "Sudah Bayar",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12.sp),
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0)),
                                backgroundColor:
                                    Colors.red, // Latar belakang merah
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal:
                                        30), // Padding agar tombol lebih besar
                              ),
                            ))
                      ],
                    ),
                  ),
          );
        }));
  }

  Future<Order?> validateOrderProductPaymentXenditGateway() async {
    ApiService apiService = ApiService(context);
    OrderResponse response = await apiService.orderGet();

    if (!response.error) {
      late Order currentOrder;

      List<Order> orders = response.data;

      for (var order in orders) {
        if (order.id == widget.order!.id) {
          currentOrder = order;
        }
      }

      if (currentOrder.orderStatus == Order.PROCESS &&
          currentOrder.xenditStatus == "PAID" &&
          paidOrder != null) {
        setState(() {
          isPaymentSuccess = true;
        });
      }
      return currentOrder;
    }
  }

  Future<FeatureOrder?> validateOrderFeaturePaymentXenditGateway() async {
    ApiService apiService = ApiService(context);
    OrderFeatureResponse response =
        await apiService.getFeatureOrder(widget.featureOrder!.id!);

    if (!response.error && response.data != null) {
      if (response.data!.paymentStatus == "PAID"&& paidFeature != null) {
        setState(() {
          isPaymentSuccess = true;
        });
      }
      return response.data;
    }
  }

  //Bug release cannot open web
  Future<void> openXenditGateway() async {
    var url;
    if (widget.order != null) {
      url = Uri.parse(widget.order!.paymentUrl!);
      try {
        await launchUrl(url, mode: LaunchMode.externalApplication).then((v) {
          validateOrderProductPaymentXenditGateway();
        });
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Terjadi kesalahan, silakan coba lagi nanti.");
      }
    } else {
      url = Uri.parse(widget.featureOrder!.paymentUrl);
      try {
        await launchUrl(url, mode: LaunchMode.externalApplication).then((v) {
          validateOrderFeaturePaymentXenditGateway();
        });
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Terjadi kesalahan, silakan coba lagi nanti.");
      }
    }
  }

  Widget paymentSuccess() {
    log.d("LOG : ${paidFeature?.paymentDate}");
    return Padding(
        padding: EdgeInsets.all(10),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                12), // Memberikan sudut melengkung pada card
          ),
          elevation: 4, // Memberikan bayangan pada card
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize
                  .min, // Card akan menyesuaikan ukuran dengan konten
              children: [
                SizedBox(
                  height: 20.h,
                ),
                Image.asset(
                  "assets/logo/jahit_baju_logo.png",
                  width: 80.h,
                ),
                SizedBox(height: 25),
                Text(
                  "Pembayaran Berhasil!",
                  style:
                      TextStyle(fontWeight: FontWeight.normal, fontSize: 14.sp),
                ),
                SizedBox(height: 5),
                Text(
                  "${convertToRupiah(paidOrder?.totalPrice ?? paidFeature?.price)}",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Divider(),
                ),
                SizedBox(height: 15), // Spasi setelah divider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order ID
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Order ID:", style: TextStyle(fontSize: 12.sp)),
                        Text("${paidOrder?.id ?? paidFeature?.id ?? "-"}",
                            style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Tanggal Pembayaran
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tanggal pembayaran:",
                            style: TextStyle(fontSize: 12.sp)),
                        (widget.order != null)
                            ? Text(
                                "${customFormatDate(paidOrder?.paymentDate?? DateTime.now())}",
                                style: TextStyle(fontSize: 12.sp))
                            : Text(
                                "${customFormatDate(paidFeature?.paymentDate ?? DateTime.now())}",
                                style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Status Pembayaran
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Status Pembayaran:",
                            style: TextStyle(fontSize: 12.sp)),
                        Text("${paidOrder?.xenditStatus ?? paidFeature?.paymentStatus}",
                            style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Metode Pembayaran
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Metode pembayaran:",
                            style: TextStyle(fontSize: 12.sp)),
                        Text("${paidOrder?.paymentMethod ?? paidFeature?.paymentMethod}",
                            style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                      (route) => false, // Menghapus semua aktivitas sebelumnya
                    );
                    context.read<HomeViewModel>().refresh();
                  },
                  child: Text(
                    "Selesai",
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    backgroundColor: Colors.red, // Latar belakang merah
                    padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 30), // Padding agar tombol lebih besar
                  ),
                ),
                SizedBox(
                  height: 20.h,
                )
              ],
            ),
          ),
        ));
  }
}
