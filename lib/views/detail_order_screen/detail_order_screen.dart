import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jahit_baju/data/model/look.dart';
import 'package:jahit_baju/data/model/packaging.dart';
import 'package:jahit_baju/data/model/shipping.dart';
import 'package:jahit_baju/data/source/remote/response/look_response.dart';
import 'package:jahit_baju/data/source/remote/response/packaging_response.dart';
import 'package:jahit_baju/data/source/remote/response/shipping_response.dart';
import 'package:jahit_baju/helper/app_color.dart';
import 'package:jahit_baju/data/model/order.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/views/payment_screen/payment_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/source/remote/response/order_response.dart';

class DetailOrderScreen extends StatefulWidget {
  final Order order;
  const DetailOrderScreen(this.order, {super.key});

  @override
  State<DetailOrderScreen> createState() => _DetailOrderScreenState();
}

class _DetailOrderScreenState extends State<DetailOrderScreen> {
  var deviceHeight, deviceWidth;
  bool buttonState = false;

  late ApiService apiService;

  List<String> status = [
    "Bayar Pesanan",
    "Pesanan Disiapkan",
    "Dalam Pengiriman",
    "Pesanan Tiba",
    "Pesanan Selesai",
  ];
  int currentStatus = 0;

  @override
  void initState() {
    apiService = ApiService(context);
    switch (widget.order.orderStatus) {
      case Order.WAITING_FOR_PAYMENT:
        currentStatus = 0;
        break;
      case Order.PROCESS:
        currentStatus = 1;
        break;
      case Order.ON_DELIVERY:
        currentStatus = 2;
        break;
      case Order.ARRIVED:
        currentStatus = 3;
        break;
      case Order.DONE:
        currentStatus = 4;
        break;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Pesanan Saya"),
        ),
        body: SingleChildScrollView(
            child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('HH:mm, EEEE, dd MMMM yyyy').format(
                        DateTime.parse(
                            widget.order.orderCreated.toIso8601String())),
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Order id :\n ${widget.order.id}",
                    style: TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 12.sp),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Status",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 1,
                    height: 8,
                  ),
                  const SizedBox(height: 5),
                  FixedTimeline.tileBuilder(
                    theme: TimelineThemeData(
                        nodePosition: 0,
                        indicatorTheme:
                            IndicatorThemeData(color: AppColor.secondary),
                        connectorTheme:
                            ConnectorThemeData(color: AppColor.primary)),
                    builder: TimelineTileBuilder.connectedFromStyle(
                        itemCount: status.length,
                        contentsBuilder: (context, index) {
                          return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                status[index],
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: index <= currentStatus
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ));
                        },
                        connectorStyleBuilder: (context, index) =>
                            ConnectorStyle.solidLine,
                        indicatorStyleBuilder: (context, index) {
                          return IndicatorStyle.dot;
                        }),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Resi:",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                  ),
                  Text(
                    widget.order.resi,
                    style: TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text("Detail Produk",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      )),
                  Divider(
                    color: Colors.black,
                    thickness: 1,
                    height: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            _listProduct(),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Detail Kemasan",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 1,
                    height: 8,
                  ),
                ],
              ),
            ),
            FutureBuilder(
              future: getPackagingById(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return itemCartShimmer();
                }
                if (snapshot.hasData && snapshot.data != null) {
                  return Card(
                      child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 2),
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(snapshot.data!.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp)),
                            Text(snapshot.data!.description,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12.sp)),
                            Text(convertToRupiah(widget.order.packagingPrice),
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12.sp))
                          ],
                        )
                      ],
                    ),
                  ));
                }
                return Text(
                  "Tidak dapat memuat detail kemasan.",
                  style: TextStyle(fontSize: 14.sp),
                );
              },
            ),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Detail Pengiriman",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 1,
                    height: 8,
                  ),
                  Text(
                    "Alamat Penerima :\n${widget.order.buyerAddress ?? "-"}",
                    style: TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            FutureBuilder<Shipping?>(
              future: getShippingById(widget.order.shippingId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasData && snapshot.data != null) {
                  return Card(
                      child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 2),
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: snapshot.data!.imgUrl,
                          errorWidget: (context, url, error) {
                            return Icon(Icons.warning);
                          },
                          width: 50,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(snapshot.data!.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp)),
                            Text(convertToRupiah(widget.order.shippingPrice))
                          ],
                        )
                      ],
                    ),
                  ));
                } else {
                  return Text(
                    "Tidak dapat memuat detail pengiriman.",
                    style: TextStyle(fontSize: 14.sp),
                  );
                }
              },
            ),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Catatan",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 1,
                    height: 8,
                  ),
                  Text(widget.order.description ?? "-",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14.sp,
                      )),
                ],
              ),
            ),
            SizedBox(height: 15),
            _detailPrice()
          ]),
        )),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Untuk distribusi tombol
            children: [
              OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: buttonState
                      ? null
                      : () async {
                          Uri url = Uri.parse("http://wa.me/+6281284844428");
                          try {
                            await launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          } catch (e, stackTrace) {
                            FirebaseCrashlytics.instance
                                .recordError(e, stackTrace);
                            Fluttertoast.showToast(
                                msg:
                                    "Terjadi kesalahan, silakan coba lagi nanti. ${e}");
                          }
                        },
                  child: Icon(
                    Icons.chat,
                    size: 14.w,
                  )),
              SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: buttonState
                      ? null
                      : currentStatus == 0
                          ? () {
                              //batal pesanan
                              _deleteOrder(widget.order.id);
                              Navigator.pop(context);
                            }
                          : () {
                              //lacak pesanan
                            },
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 5, // Jarak antara ikon dan teks
                    children: [
                      Text(
                        currentStatus == 0 ? "Batal" : "Lacak",
                        style: TextStyle(
                            color: buttonState
                                ? const Color.fromARGB(255, 95, 92, 92)
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp),
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: buttonState ? Colors.grey : Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: buttonState
                      ? null
                      : currentStatus == 0
                          ? () {
                              //bayar pesanan
                              _goToPaymentScreen(widget.order);
                            }
                          : currentStatus != 3
                              ? null
                              : () {
                                  //pesanan selesai
                                },
                  child: currentStatus != 3 && currentStatus == 0
                      ? Text(
                          "Bayar Sekarang",
                          style: TextStyle(
                              color: buttonState
                                  ? const Color.fromARGB(255, 95, 92, 92)
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp),
                          softWrap:
                              true, // Agar teks membungkus jika terlalu panjang
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          "Pesanan Selesai",
                          style: TextStyle(
                              color: buttonState
                                  ? const Color.fromARGB(255, 95, 92, 92)
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp),
                          softWrap:
                              true, // Agar teks membungkus jika terlalu panjang
                          textAlign: TextAlign.center,
                        ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _listProduct() {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.order.items.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (widget.order.items[index].customDesign != null) {
            return FutureBuilder<Look?>(
                future: getLook(widget.order.items[index].lookId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return itemCartShimmer();
                  }
                  if (snapshot.hasData) {
                    return Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(width: 2)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              height: 130.h,
                              padding: const EdgeInsets.all(5),
                              color: Colors.white,
                              child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8)),
                                  child: AspectRatio(
                                      aspectRatio: 4 / 5,
                                      child: FutureBuilder(
                                        future: apiService.getCustomDesign(
                                            widget.order.items[index]
                                                .customDesign!),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }

                                          return svgViewer(
                                              snapshot.data!['data']);
                                        },
                                      )))),
                          Expanded(
                            child: Container(
                              color: Colors.white,
                              margin: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        snapshot.data?.name ?? "Nama Produk",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.sp),
                                      ),
                                      Text(
                                        convertToRupiah(
                                            widget.order.items[index].price),
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                      Text(
                                        '${widget.order.items[index].size}',
                                        style: TextStyle(fontSize: 12.sp),
                                      )
                                    ],
                                  ),
                                  Container(
                                      padding: const EdgeInsets.all(3),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${widget.order.items[index].quantity} pcs",
                                            style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ))
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  } else {
                    return Text("Tidak dapat memuat detail produk.",
                        style: TextStyle(
                          fontSize: 12.sp,
                        ));
                  }
                });
          }
          return FutureBuilder<Product?>(
              future: getProductById(
                  widget.order.items[index].productId, ApiService(context)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return itemCartShimmer();
                }
                if (snapshot.hasData || snapshot.data != null) {
                  return Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(width: 2)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            height: 130.h,
                            padding: const EdgeInsets.all(5),
                            color: Colors.white,
                            child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8)),
                                child: AspectRatio(
                                    aspectRatio: 4 / 5,
                                    child: CachedNetworkImage(
                                      imageUrl: snapshot.data!.imageUrl.first,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) {
                                        return Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              color: Colors.grey,
                                            ));
                                      },
                                    )))),
                        Expanded(
                          child: Container(
                            color: Colors.white,
                            margin: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data?.name ?? "Nama Produk",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp),
                                    ),
                                    Text(
                                      convertToRupiah(
                                          widget.order.items[index].price),
                                      style: TextStyle(fontSize: 12.sp),
                                    ),
                                    Text(
                                      '${widget.order.items[index].size}',
                                      style: TextStyle(fontSize: 12.sp),
                                    )
                                  ],
                                ),
                                Container(
                                    padding: const EdgeInsets.all(3),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${widget.order.items[index].quantity} pcs",
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                } else {
                  return Text("Tidak dapat memuat detail produk.",
                      style: TextStyle(
                        fontSize: 12.sp,
                      ));
                }
              });
        });
  }

  _detailPrice() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Siap pakai",
              style: TextStyle(fontSize: 12.sp),
            ),
            Text(
              convertToRupiah(widget.order.rtwPrice),
              style: TextStyle(fontSize: 12.sp),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Kustom",
              style: TextStyle(fontSize: 12.sp),
            ),
            Text(
              convertToRupiah(widget.order.customPrice),
              style: TextStyle(fontSize: 12.sp),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Jasa Pengiriman",
                style: TextStyle(
                  fontSize: 12.sp,
                )),
            Text(
              convertToRupiah(widget.order.shippingPrice),
              style: TextStyle(fontSize: 12.sp),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Packaging",
              style: TextStyle(fontSize: 12.sp),
            ),
            Text(
              convertToRupiah(widget.order.packagingPrice),
              style: TextStyle(fontSize: 12.sp),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Diskon",
              style: TextStyle(fontSize: 12.sp),
            ),
            Text(
              "-" + convertToRupiah(widget.order.discount),
              style: TextStyle(fontSize: 12.sp),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            Text(
              convertToRupiah(widget.order.totalPrice),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ],
        ),
      ],
    );
  }

  void _deleteOrder(String? id) async {
    ApiService apiService = ApiService(context);
    OrderResponse response = await apiService.orderDelete(id);
    if (response.error) {
      Fluttertoast.showToast(msg: response.message!);
    } else {
      Fluttertoast.showToast(msg: response.message!);
      setState(() {});
    }
  }

  void _goToPaymentScreen(order) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PaymentScreen(order: order)));
  }

  Future<Shipping?> getShippingById(String shippingId) async {
    ShippingResponse response =
        await ApiService(context).getShipping(widget.order.shippingId);
    if (response.error) {
      if (response.message != null) {
        Fluttertoast.showToast(msg: response.message!);
      } else {
        Fluttertoast.showToast(msg: "Terjadi kesalahan, coba lagi nanti.");
      }
    } else {
      return response.shipping;
    }
    return null;
  }

//get packaging
  Future<Packaging?> getPackagingById() async {
    PackagingResponse response =
        await ApiService(context).getPackaging(widget.order.packagingId);
    if (response.error) {
      if (response.message != null) {
        Fluttertoast.showToast(msg: response.message!);
      } else {
        Fluttertoast.showToast(msg: "Terjadi kesalahan, coba lagi nanti.");
      }
    } else {
      return response.packaging;
    }
    return null;
  }

  Future<Look?> getLook(String lookId) async {
    ApiService apiService = ApiService(context);
    LookResponse response = await apiService.getLookGetById(lookId);
    if (response.error) {
      Fluttertoast.showToast(msg: response.message!);
    } else {
      return response.look!;
    }
  }
}
