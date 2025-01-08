import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/home_view_model.dart';
import 'package:jahit_baju/views/shipping_screen/shipping_screen.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xml/xml.dart';

class DesignConfirmPage extends StatefulWidget {
  final String html;
  final Map<String, String> currentFeatureColor;
  final Product product;
  final String size;
  final String customDesignSvg;

  const DesignConfirmPage(this.customDesignSvg,
      this.html, this.currentFeatureColor, this.product, this.size,
      {super.key});

  @override
  State<DesignConfirmPage> createState() => _DesignConfirmPageState();
}

class _DesignConfirmPageState extends State<DesignConfirmPage> {
  late WebViewController _controller;
  late double deviceWidth;
  late Logger log;

  bool purchaseLoading = false;
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();    
    log = Logger();
    _controller = WebViewController();
    _controller.enableZoom(false);
    _controller.loadHtmlString(widget.html);
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Konfirmasi Pesanan"),
        ),
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
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed:purchaseLoading ? null: () =>
                    addToCart()
                  ,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 5, // Jarak antara ikon dan teks
                    children: [
                      Icon(
                              Icons.shopping_bag,
                              color: purchaseLoading?const Color.fromARGB(255, 95, 92, 92) :Colors.black,
                            ),
                            Text(
                              "Tambah ke Keranjang",
                              style: TextStyle(
                                color: purchaseLoading?const Color.fromARGB(255, 95, 92, 92) :Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap:
                                  true, 
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
                    backgroundColor: purchaseLoading? Colors.grey : Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed:purchaseLoading ? null: () =>buyNow(context, widget.size, widget.product),
                  child: Text(
                    "Beli Sekarang",
                    style: TextStyle(
                      color: purchaseLoading?const Color.fromARGB(255, 95, 92, 92) :Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true, // Agar teks membungkus jika terlalu panjang
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Container(
                height: 400,
                child: Row(
                  children: [
                    _textureWidget(),
                    Container(
                      width: deviceWidth * 0.7,
                      padding: const EdgeInsets.all(10),
                      child: WebViewWidget(controller: _controller),
                    ),
                  ],
                )),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                      Text(
                        convertToRupiah(widget.product.price),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Ukuran:",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        width: 50,
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFAAAA),
                        ),
                        child: Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            widget.size,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                ],
              ),
            )
          ],
        )));
  }


  void addToCart() async {        
    setState(() {
      purchaseLoading = true;
    });

    var msg = await apiService.cartAdd(widget.product, 1, widget.size, widget.customDesignSvg);
    Fluttertoast.showToast(msg: msg);
    setState(() {
      purchaseLoading = true;
    });
    
    setState(() {
      purchaseLoading = false;
    });
  }

  Widget _textureWidget() {
    return Container(
      width: deviceWidth * 0.3,
      child: ListView(
        children: widget.currentFeatureColor.entries.map((entry) {
          final feature = entry.key;
          final color = entry.value;

          return Column(children: [
            Text(
              feature.toString().replaceAll("-", " "),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: deviceWidth * 0.03),
            ),
            color.contains("https")?
            Container(
              clipBehavior: Clip.hardEdge,
              width: deviceWidth * 0.08,
              height: deviceWidth * 0.08,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey, 
              ),
              child:CachedNetworkImage(
                              imageUrl: color,
                              placeholder: (context, url) => Padding(
                                  padding: EdgeInsets.all(5),
                                  child: CircularProgressIndicator()),
                              fit: BoxFit.cover,
                            ),
            ) : Container(
              clipBehavior: Clip.hardEdge,
              width: deviceWidth * 0.08,
              height: deviceWidth * 0.08,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(int.parse(
                    color.replaceFirst('#', '0xFF'))), // Gunakan warna dari Map
              ),
            )
          ]);
        }).toList(),
      ),
    );
  }
}


void buyNow(BuildContext context, String size, Product? product) {
  if (size == "" && size.isEmpty) {
    Fluttertoast.showToast(msg: "Silakan pilih ukuran terlebih dahulu.");
    return;
  }

  if (product == null) {
    Fluttertoast.showToast(msg: "Terjadi kesalahan, silakan coba lagi.");
    return;
  }

  goToShippingScreen(context, product, size);
}


void goToShippingScreen(BuildContext context, Product? product, String size) {
  if (product != null) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShippingScreen(
                  cart: null,
                  product: product,
                  size: size,
                )));
  } else {
    Fluttertoast.showToast(
        msg: "Tidak ada produk, silakan belanja terlebih dahulu.");
  }
}
