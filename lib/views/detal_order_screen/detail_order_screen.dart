import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jahit_baju/helper/app_color.dart';
import 'package:jahit_baju/model/cart.dart';
import 'package:jahit_baju/model/order.dart';
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/service/remote/response/product_response.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timelines_plus/timelines_plus.dart';

class DetailOrderScreen extends StatefulWidget {
  final Order order;
  const DetailOrderScreen(this.order, {super.key});

  @override
  State<DetailOrderScreen> createState() => _DetailOrderScreenState();
}

class _DetailOrderScreenState extends State<DetailOrderScreen> {
  var deviceHeight, deviceWidth;
  bool buttonState = false;

  var fontSize;

  List<String> status = [
    "Pesanan Disiapkan",
    "Dalam Pengiriman",
    "Pesanan Tiba"
  ];
  int currentStatus = 0;

  @override
  void initState() {
    switch (widget.order.orderStatus) {
      case Order.PROCESS:
        currentStatus = 0;
        break;
      case Order.ON_DELIVERY:
        currentStatus = 1;
        break;
      case Order.DONE:
        currentStatus = 2;
        break;
    }

    super.initState();
  }

  ApiService apiService = ApiService();
  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    fontSize = deviceWidth * 0.035;

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
                    DateFormat('HH:mm,EEEE, dd MMMM yyyy').format(DateTime.parse(
                        widget.order.orderCreated.toIso8601String())),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Status",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: fontSize),
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
                                  fontSize: 14,
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
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: fontSize * 0.8),
                  ),
                  Text(
                    widget.order.resi,
                    style: TextStyle(
                        fontWeight: FontWeight.normal, fontSize: fontSize),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Text(
                    "Detail Produk",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: fontSize),
                  ),
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
              // Tombol Tambah ke Keranjang
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
                  onPressed: buttonState ? null : () {},
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 5, // Jarak antara ikon dan teks
                    children: [
                      Text(
                        "Lacak",
                        style: TextStyle(
                          color: buttonState
                              ? const Color.fromARGB(255, 95, 92, 92)
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
              // Tombol Beli Sekarang
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: buttonState ? Colors.grey : Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {},
                  child: Text(
                    "Pesanan Selesai",
                    style: TextStyle(
                      color: buttonState
                          ? const Color.fromARGB(255, 95, 92, 92)
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true, // Agar teks membungkus jika terlalu panjang
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
        itemCount: widget.order.items.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return FutureBuilder<Product?>(
              future: getProductById(widget.order.items[index].productId),
              builder: (context, snapshot) {

                if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(
                    child: CircularProgressIndicator(),
                  ); 
                }
                if (snapshot.hasData) {
                  return Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(width: 1)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            height: deviceWidth * 0.3,
                            padding: const EdgeInsets.all(5),
                            color: Colors.white,
                            child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8)),
                                child: AspectRatio(
                                    aspectRatio: 4 / 5,
                                    child: snapshot.data!.type ==
                                            Product.READY_TO_WEAR
                                        ? CachedNetworkImage(
                                            imageUrl:
                                                snapshot.data!.imageUrl.first,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) {
                                              return Shimmer.fromColors(
                                                  baseColor: Colors.grey[300]!,
                                                  highlightColor:
                                                      Colors.grey[100]!,
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    color: Colors.grey,
                                                  ));
                                            },
                                          )
                                        : svgViewer(widget.order.items[index]
                                            .customDesign!)))),
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
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    Text(
                                      convertToRupiah(
                                          widget.order.items[index].price),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      '${widget.order.items[index].size}',
                                      style: const TextStyle(fontSize: 12),
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
                                          style: const TextStyle(
                                              fontSize: 12,
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
                }else{
                  return Container();
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
              style: TextStyle(fontSize: fontSize),
            ),
            Text(
              convertToRupiah(widget.order.rtwPrice),
              style: TextStyle(fontSize: fontSize),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Custom",
              style: TextStyle(fontSize: fontSize),
            ),
            Text(
              convertToRupiah(widget.order.customPrice),
              style: TextStyle(fontSize: fontSize),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Jasa Pengiriman",
              style: TextStyle(fontSize: fontSize),
            ),
            Text(
              convertToRupiah(widget.order.shippingPrice),
              style: TextStyle(fontSize: fontSize),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Packaging",
              style: TextStyle(fontSize: fontSize),
            ),
            Text(
              convertToRupiah(widget.order.packagingPrice),
              style: TextStyle(fontSize: fontSize),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Diskon",
              style: TextStyle(fontSize: fontSize),
            ),
            Text(
              "-" + convertToRupiah(widget.order.discount),
              style: TextStyle(fontSize: fontSize),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
            ),
            Text(
              convertToRupiah(widget.order.totalPrice),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
            ),
          ],
        ),
      ],
    );
  }
}
