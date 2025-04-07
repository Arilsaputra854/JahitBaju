import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jahit_baju/data/model/look_order.dart';
import 'package:jahit_baju/data/source/remote/response/feature_order_reaspones.dart';
import 'package:jahit_baju/data/source/remote/response/look_order_response.dart';
import 'package:jahit_baju/viewmodels/home_screen_view_model.dart';
import 'package:logger/web.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/model/order.dart';
import 'package:jahit_baju/data/source/remote/response/order_response.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/home_view_model.dart';
import 'package:jahit_baju/viewmodels/payment_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/model/feature_order.dart';
import '../home_screen/home_screen.dart';

class PaymentScreen extends StatefulWidget {
  Order? order;
  FeatureOrder? featureOrder;
  LookOrder? lookOrder;
  PaymentScreen({this.order, this.featureOrder, this.lookOrder, super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  var isPaymentSuccess = false;
  Order? paidOrder;
  FeatureOrder? paidFeature;
  LookOrder? paidLook;
  Logger log = Logger();

  @override
  Widget build(BuildContext context) {
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
                    width: 360.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/logo/jahit_baju_logo.png",
                          width: 200.w,
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
                            "Id : ${widget.order?.id ?? widget.featureOrder?.id ?? widget.lookOrder?.id ?? ""}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12.sp)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                            "Total Harga : ${convertToRupiah(widget.order?.totalPrice ?? widget.featureOrder?.price ?? widget.lookOrder?.price)}",
                            style: TextStyle(fontSize: 12.sp)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                            "Bayar sebelum ${customFormatDate(widget.order?.expiredDate ?? widget.featureOrder?.expiryDate ?? widget.lookOrder?.expiredDate ?? DateTime(2099))}",
                            style: TextStyle(fontSize: 12.sp)),
                        SizedBox(
                          height: 40,
                        ),
                        SizedBox(
                          width: 200.w,
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
                            width: 200.w,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (widget.order != null) {
                                  paidOrder =
                                      await validateOrderProductPaymentXenditGateway();
                                  log.d("Paid Order : ${paidOrder}");
                                } else if (widget.featureOrder != null) {
                                  paidFeature =
                                      await validateOrderFeaturePaymentXenditGateway();
                                  log.d("Paid Feature : ${paidFeature}");
                                } else if (widget.lookOrder != null) {
                                  paidLook =
                                      await validateLookOrderPaymentXenditGateway();
                                  log.d("Paid Look : ${paidLook}");
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
      if (response.data!.paymentStatus == "PAID" && paidFeature != null) {
        setState(() {
          isPaymentSuccess = true;
        });
      }
      return response.data;
    }
  }

  Future<LookOrder?> validateLookOrderPaymentXenditGateway() async {
    ApiService apiService = ApiService(context);
    LookOrderResponse response =
        await apiService.getLookOrder(widget.lookOrder!.id!);

    if (!response.error && response.look != null) {
      if (response.look!.paymentStatus == "PAID" && paidLook != null) {
        setState(() {
          isPaymentSuccess = true;
        });
      }
      return response.look;
    }
  }

  Future<void> openXenditGateway() async {
    var url;
    if (widget.order != null) {
      url = Uri.parse(widget.order!.paymentUrl!);
      try {
        await launchUrl(url, mode: LaunchMode.externalApplication).then((v) {
          validateOrderProductPaymentXenditGateway();
        });
      } catch (e, stackTrace) {
        FirebaseCrashlytics.instance.recordError(e, stackTrace);
        Fluttertoast.showToast(msg: "Terjadi kesalahan, Error ${e}");
      }
    } else if (widget.featureOrder != null) {
      url = Uri.parse(widget.featureOrder!.paymentUrl);
      try {
        await launchUrl(url, mode: LaunchMode.externalApplication).then((v) {
          validateOrderFeaturePaymentXenditGateway();
        });
      } catch (e, stackTrace) {
        FirebaseCrashlytics.instance.recordError(e, stackTrace);
        Fluttertoast.showToast(
            msg: "Terjadi kesalahan, silakan coba lagi nanti.");
      }
    } else if (widget.lookOrder != null) {
      url = Uri.parse(widget.lookOrder!.paymentUrl!);
      try {
        await launchUrl(url, mode: LaunchMode.externalApplication).then((v) {
          validateLookOrderPaymentXenditGateway();
        });
      } catch (e, stackTrace) {
        FirebaseCrashlytics.instance.recordError(e, stackTrace);
        Fluttertoast.showToast(
            msg: "Terjadi kesalahan, silakan coba lagi nanti.");
      }
    }
  }

  Widget paymentSuccess() {
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
                  "${convertToRupiah(paidOrder?.totalPrice ?? paidFeature?.price ?? paidLook?.price)}",
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
                        Text(
                            "${paidOrder?.id ?? paidFeature?.id ?? paidLook?.id}",
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
                                "${customFormatDate(paidOrder?.paymentDate ?? DateTime.now())}",
                                style: TextStyle(fontSize: 12.sp))
                            : widget.featureOrder != null
                                ? Text(
                                    "${customFormatDate(paidFeature?.paymentDate ?? DateTime.now())}",
                                    style: TextStyle(fontSize: 12.sp))
                                : Text(
                                    "${customFormatDate(paidLook?.paymentDate ?? DateTime.now())}",
                                    style: TextStyle(fontSize: 12.sp))
                      ],
                    ),
                    SizedBox(height: 8),
                    // Status Pembayaran
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Status Pembayaran:",
                            style: TextStyle(fontSize: 12.sp)),
                        Text(
                            "${paidOrder?.xenditStatus ?? paidFeature?.paymentStatus ?? paidLook?.paymentStatus}",
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
                        Text(
                            "${paidOrder?.paymentMethod ?? paidFeature?.paymentMethod ?? paidLook?.paymentMethod}",
                            style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<HomeScreenViewModel>(context, listen: false)
                        .refresh();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                      (route) => false, // Menghapus semua aktivitas sebelumnya
                    );
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
