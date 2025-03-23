import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/model/look.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/cart_response.dart';
import 'package:jahit_baju/data/source/remote/response/custom_design_response.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/home_view_model.dart';
import 'package:jahit_baju/views/shipping_screen/shipping_screen.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xml/xml.dart';
import 'package:path_provider/path_provider.dart';

class DesignConfirmPage extends StatefulWidget {
  final String html;
  final Map<String, String> currentFeatureColor;
  final Look look;
  final String size;
  final String customDesignSvg;

  const DesignConfirmPage(this.customDesignSvg, this.html,
      this.currentFeatureColor, this.look, this.size,
      {super.key});

  @override
  State<DesignConfirmPage> createState() => _DesignConfirmPageState();
}

class _DesignConfirmPageState extends State<DesignConfirmPage> {
  late WebViewController _controller;
  late double deviceWidth;
  late Logger log;

  bool loading = false;
  late ApiService apiService;

  @override
  void initState() {
    apiService = ApiService(context);
    super.initState();
    log = Logger();
    _controller = WebViewController();
    _controller.enableZoom(false);
    _controller.loadHtmlString(widget.html);
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Scaffold(
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
                      onPressed: loading ? null : () => addToCart(),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 5, // Jarak antara ikon dan teks
                        children: [
                          Icon(
                            Icons.shopping_bag,
                            color: loading
                                ? const Color.fromARGB(255, 95, 92, 92)
                                : Colors.black,
                          ),
                          Text(
                            "Tambah ke Keranjang",
                            style: TextStyle(
                              color: loading
                                  ? const Color.fromARGB(255, 95, 92, 92)
                                  : Colors.black,
                              fontSize: 12.sp,
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
                        backgroundColor: loading ? Colors.grey : Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: loading
                          ? null
                          : () => buyNow(widget.customDesignSvg, context,
                              widget.size, widget.look),
                      child: Text(
                        "Beli Sekarang",
                        style: TextStyle(
                          color: loading
                              ? const Color.fromARGB(255, 95, 92, 92)
                              : Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap:
                            true, // Agar teks membungkus jika terlalu panjang
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
                    height: 400.h,
                    child: Row(
                      children: [
                        _textureWidget(),
                        Container(
                          width: 250.w,
                          height: 400.h,
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
                            widget.look.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.sp),
                          ),
                          Text(
                            convertToRupiah(widget.look.price),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "Ukuran:",
                            style: TextStyle(
                              fontSize: 14.sp,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(5),
                            width: 40.w,
                            height: 40.w,
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
                                  fontSize: 10.sp,
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
            ))),
        if (loading) loadingWidget()
      ],
    );
  }

  void addToCart() async {
    setState(() {
      loading = true;
    });
    try {
      // 1. Convert customDesignSvg (SVG string) to a file
      String svgContent = widget.customDesignSvg;
      File svgFile = await _writeSvgToFile(svgContent);

      // 2. Upload the custom design file
      CustomDesignResponse? response =
          await apiService.uploadCustomDesign(svgFile);

      if (response != null && !response.error) {
        // 3. Add to cart with the uploaded design's filename
        CartResponse? cartResponse = await apiService.cartAdd(
          look: widget.look,
          quantity: 1,
          selectedSize: widget.size,
          customDesignSvg: response.file!.filename, weight: widget.look.weight,          
        );

        if (cartResponse != null && cartResponse.error) {
          Fluttertoast.showToast(
              msg: cartResponse.message ?? ApiService.SOMETHING_WAS_WRONG);
        } else {
          Fluttertoast.showToast(
              msg: "Berhasil menambahkan produk ke keranjang.");
        }
      } else {
        // Handle upload failure
        Fluttertoast.showToast(msg: "Gagal menyimpan desain, coba lagi nanti.");
      }
    } catch (e,stackTrace) {
        FirebaseCrashlytics.instance.recordError(e, stackTrace);
      // Handle any errors that occur during the process
      Fluttertoast.showToast(msg: "Terjadi kesalahan");
    }

    setState(() {
      loading = false;
    });
  }

  Widget _textureWidget() {
    return Container(
      width: 100.w,
      padding: EdgeInsets.only(left: 10),
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
            color.contains("https")
                ? Container(
                    clipBehavior: Clip.hardEdge,
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: color,
                      placeholder: (context, url) => Padding(
                          padding: EdgeInsets.all(5),
                          child: CircularProgressIndicator()),
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    clipBehavior: Clip.hardEdge,
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(int.parse(color.replaceFirst(
                          '#', '0xFF'))), // Gunakan warna dari Map
                    ),
                  )
          ]);
        }).toList(),
      ),
    );
  }

  Future<void> buyNow(String customDesignSvg, BuildContext context, String size,
      Look? look) async {
    if (size == "" && size.isEmpty) {
      Fluttertoast.showToast(msg: "Silakan pilih ukuran terlebih dahulu.");
      return;
    }

    if (look == null) {
      Fluttertoast.showToast(msg: "Terjadi kesalahan, silakan coba lagi.");
      return;
    }

    setState(() {
      loading = true;
    });
    try {
      // 1. Convert customDesignSvg (SVG string) to a file
      File svgFile = await _writeSvgToFile(customDesignSvg);

      // 2. Upload the custom design file
      CustomDesignResponse? response =
          await apiService.uploadCustomDesign(svgFile);
      if (response!.file!.filename != null) {
        goToShippingScreen(context, look, size, response!.file!.filename);
      } else {
        Fluttertoast.showToast(msg: ApiService.SOMETHING_WAS_WRONG);
      }
    } catch (e) {}
    setState(() {
      loading = false;
    });
  }
}

_writeSvgToFile(String svgContent) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/custom_design.svg');
  await file.writeAsString(svgContent); // Write the SVG string to the file
  return file;
}

void goToShippingScreen(
    BuildContext context, Look? look, String size, String filename) {
  if (look != null) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShippingScreen(
                  cart: null,
                  look: look,
                  size: size,
                  filename: filename,
                )));
  } else {
    Fluttertoast.showToast(
        msg: "Tidak ada produk, silakan belanja terlebih dahulu.");
  }
}
