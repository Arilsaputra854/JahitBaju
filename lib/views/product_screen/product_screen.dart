import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/model/favorite.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/model/cart.dart';
import 'package:jahit_baju/model/order.dart';
import 'package:jahit_baju/model/order_item.dart';
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/service/remote/response/favorite_response.dart';
import 'package:jahit_baju/service/remote/response/size_guide_response.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/home_view_model.dart';
import 'package:jahit_baju/views/cart_screen/cart_screen.dart';
import 'package:jahit_baju/views/product_screen/design_confirm_page.dart';
import 'package:jahit_baju/views/shipping_screen/shipping_screen.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class ProductScreen extends StatefulWidget {
  final Product product;
  const ProductScreen(this.product, {super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late WebViewController _controller;

  var _selectedSize = "";
  var deviceWidth;

  var currentSvg = "";

  var updatedSvg;
  var rendering = false;

  late bool isFavorited;
  late int favoriteId;

  List<String> svgColor = [];
  List<String> svgFeatures = [];

  Map<String, String> currentFeatureColor = {};

  late String htmlContent;

  String? currentColor;
  String? currentFeature;

  Logger log = Logger();

  bool purchaseLoading = false;

  @override
  void initState() {
    isFavorited = false;

    if (widget.product.type == Product.CUSTOM) {
      _controller = WebViewController();
      _controller.enableZoom(false);

      svgColor = widget.product.colors!;
      svgFeatures = widget.product.features!;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.product.type == Product.READY_TO_WEAR
              ? "Siap Pakai"
              : "Custom Produk"),
        ),
        body: SingleChildScrollView(
            child: widget.product.type == Product.READY_TO_WEAR
                ? showRTW()
                : showCustom()),
        bottomNavigationBar: widget.product.type == Product.READY_TO_WEAR
            ? Container(
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
                        onPressed: purchaseLoading ? null:  () => addToCart(),
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
                        onPressed: () {
                          buyNow(context, _selectedSize, widget.product);
                        },
                        child: Text(
                          "Beli Sekarang",
                          style: TextStyle(
                            color: purchaseLoading?const Color.fromARGB(255, 95, 92, 92) :Colors.white,
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
              )
            : Container(
                padding: EdgeInsets.all(20),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      backgroundColor: Colors.red,
                      disabledBackgroundColor: Colors.grey,
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    ),
                    onPressed: currentSvg.contains("none")? null :  () {
                      goToDesignConfirmation(htmlContent);
                    },
                    child: Text(
                      "Selanjutnya",
                      style: TextStyle(
                        color: currentSvg.contains("none")? Colors.black:Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ))));
  }

  showRTW() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          child: Container(
              color: Colors.black,
              height: deviceWidth * 0.7,
              width: deviceWidth,
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Image.network(
                  alignment: Alignment(1, -0.3),
                  widget.product.imageUrl[0],
                  fit: BoxFit.cover,
                ),
              )),
          onTap: () {
            SwipeImageGallery(
              context: context,
              itemBuilder: (context, indexImage) {
                return Image.network(widget.product.imageUrl[indexImage]);
              },
              itemCount: widget.product.imageUrl.length,
            ).show();
          },
        ),
        Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 5, // Jarak horizontal antar tag
                      runSpacing: 5, // Jarak vertikal antara baris tag
                      children: widget.product.tags.map((tag) {
                        return Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Teks harga
                  Text(
                    convertToRupiah(widget.product.price),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${widget.product.sold} Terjual | ${widget.product.seen} Favorit | ${widget.product.stock} Stok \n${widget.product.seen} Orang melihat produk ini",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  FutureBuilder(
                      future: getFavoriteStatus(),
                      builder: (context, snapshot) {
                        return IconButton(
                            onPressed: () {
                              addProductFavorite(widget.product);
                            },
                            icon: IconButton(
                                onPressed: () {
                                  addProductFavorite(widget.product);
                                },
                                icon: isFavorited
                                    ? Icon(Icons.favorite)
                                    : Icon(Icons.favorite_border)));
                      })
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Deskripsi",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                widget.product.description,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Panduan Ukuran",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              sizeGuideWidget(),
              SizedBox(
                height: 20,
              ),
              Text(
                "Pilih Ukuran",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              _sizeWidget()
            ],
          ),
        )
      ],
    );
  }

  showCustom() {
    return Column(
      children: [
        Container(
            height: 400,
            child: Row(
              children: [
                _featureWidget(),
                customPreview(),
              ],
            )),
        _textureWidget(),
        Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${widget.product.sold} Terjual | ${widget.product.seen} Favorit | ${widget.product.stock} Stok \n${widget.product.seen} Orang melihat produk ini",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    FutureBuilder(
                        future: getFavoriteStatus(),
                        builder: (context, snapshot) {
                          return IconButton(
                              onPressed: () {
                                addProductFavorite(widget.product);
                              },
                              icon: IconButton(
                                  onPressed: () {
                                    addProductFavorite(widget.product);
                                  },
                                  icon: isFavorited
                                      ? Icon(Icons.favorite)
                                      : Icon(Icons.favorite_border)));
                        })
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Deskripsi",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  widget.product.description,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Panduan Ukuran",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                sizeGuideWidget(),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Pilih Ukuran",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                _sizeWidget()
              ],
            ))
      ],
    );
  }

  goToCartScreen() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CartScreen()));
  }

  addToCart() async {
    setState(() {
      purchaseLoading = true;
    });
    ApiService apiService = ApiService();

    if (_selectedSize != "" && _selectedSize.isNotEmpty) {
      var msg = await apiService.cartAdd(widget.product, 1, _selectedSize, null);
      setState(() {
        purchaseLoading = false;
      });
      Fluttertoast.showToast(msg: msg);
    } else {
      Fluttertoast.showToast(msg: "Silakan pilih ukuran terlebih dahulu");
    }
  }

  Future getFavoriteStatus() async {
    ApiService apiService = ApiService();
    List<Favorite> favorites = await apiService.favoriteGet();

    if (favorites.isNotEmpty) {
      favorites.forEach((favorite) {
        if (favorite.productId == widget.product.id) {
          favoriteId = favorite.id!;
          isFavorited = true;
        } else {
          isFavorited = false;
        }
      });
    }
  }

  Future<void> addProductFavorite(Product product) async {
    ApiService apiService = ApiService();

    Favorite favorite = Favorite(productId: product.id);

    if (!isFavorited) {
      FavoriteResponse response = await apiService.favoriteAdd(favorite);
      if (response.error) {
        Fluttertoast.showToast(msg: "${response.message}");
      } else {
        favoriteId = response.id!;

        setState(() {});
        Fluttertoast.showToast(msg: "Berhasil menambahkan ke favorit.");
      }
    } else {
      FavoriteResponse response = await apiService.favoriteDelete(favoriteId);

      if (response.error) {
        Fluttertoast.showToast(msg: "${response.message}");
      } else {
        setState(() {
          isFavorited = false;
        });
        Fluttertoast.showToast(msg: "Berhasil menghapus produk.");
      }
    }
  }

  _textureWidget() {
    return svgColor.isNotEmpty
        ? Container(
            padding: EdgeInsets.all(2),
            color: Colors.white,
            height: deviceWidth * 0.1,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: svgColor.length,
              itemBuilder: (context, index) {
                return InkWell(
                    onTap: () async {
                      try {
                        if (currentFeature != "") {
                          setState(() {
                            rendering = true;
                            // Mengubah warna atau texture sesuai kondisi
                            currentColor = svgColor[index];
                          });

                          if (svgColor[index].contains("https")) {                            

                            // Ambil dan konversi gambar ke Base64
                            String? base64Image =
                                await fetchAndConvertToBase64(currentColor!);

                            if (base64Image != null) {
                              updatedSvg = addPatternToSvg(
                                  currentSvg, base64Image, currentFeature!);
                            }
                          } else {                            

                            // Jika tidak ada URL gambar, lakukan perubahan warna biasa
                            updatedSvg = updateFillColorByIdWithColor(
                                currentSvg, currentFeature!, currentColor!);
                          }

                          // Setelah selesai, update currentSvg
                          setState(() {
                            rendering = false;
                            currentFeatureColor[currentFeature!] =
                                currentColor!;
                            currentSvg = updatedSvg;
                          });
                        }
                      } catch (e) {
                        Fluttertoast.showToast(
                            msg:
                                "Silakan pilih bagian yang mau di masukkan warna atau ulos.");
                      }
                    },
                    child: svgColor[index].contains("https")
                        ? Container(
                            clipBehavior: Clip.hardEdge,
                            width: deviceWidth * 0.1,
                            height: deviceWidth * 0.1,
                            margin: EdgeInsets.symmetric(
                                horizontal: deviceWidth * 0.01),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.white),
                            child: CachedNetworkImage(
                              imageUrl: svgColor[index],
                              placeholder: (context, url) => Padding(
                                  padding: EdgeInsets.all(5),
                                  child: CircularProgressIndicator()),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: deviceWidth * 0.1,
                            height: deviceWidth * 0.1,
                            margin: EdgeInsets.symmetric(
                                horizontal: deviceWidth * 0.01),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(int.parse(
                                  svgColor[index].replaceFirst('#', '0xFF'))),
                            ),
                          ));
              },
            ),
          )
        : smimmerTag();
  }

  Widget smimmerTag() {
    return Container(
      height: deviceWidth * 0.1,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Number of placeholder items
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: deviceWidth * 0.1,
              height: deviceWidth * 0.1,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }

  String addPatternToSvg(String svg, String base64, String patternId) {
    // Cari apakah sudah ada <defs> dengan patternId yang diberikan
    final defsPattern = RegExp(
        r'<defs>.*?<pattern id="$patternId".*?</pattern>.*?</defs>',
        dotAll: true);

    if (defsPattern.hasMatch(svg)) {
      // Jika sudah ada, update href di dalam <image> dengan imageUrl baru
      final updatedSvg = svg.replaceFirst(
        RegExp(r'(<pattern id="$patternId".*?<image href=").*?(".*?/>)'),
        '\$1$base64\$2',
      );
      return updateFillColorByIdWithPattern(updatedSvg, patternId, patternId);
    } else {
      // Jika belum ada, tambahkan <defs> beserta pattern baru sebelum <g>
      final patternDefinition = '''
    <defs>
      <pattern id="$patternId" patternUnits="userSpaceOnUse" width="200" height="500">
        <image href="data:image/png;base64,$base64" x="0" y="0" width="200" height="500" />
      </pattern>
    </defs>
    ''';

      // Cari tag <g> dan masukkan <defs> sebelum tag tersebut
      var updatedSvg = svg.replaceFirst(RegExp(r'<g'), '$patternDefinition<g');

      // Ganti fill pada elemen dengan ID yang sesuai
      var updatedSvgWithPattern =
          updateFillColorByIdWithPattern(updatedSvg, patternId, patternId);

      return updatedSvgWithPattern;
    }
  }

  customPreview() {
    //dari server
    if (currentSvg == "") {
      return FutureBuilder(
          future: fetchSvg(widget.product.imageUrl.first),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                width: deviceWidth * 0.65,
                height: 400, child: Center(child: CircularProgressIndicator(),));
            }
            if (snapshot.hasData) {
              currentSvg = snapshot.data!;
              htmlContent = '''
            <!DOCTYPE html>
            <html lang="en">
            <head>
              <meta name="viewport" content="width=device-width, initial-scale=0.7, maximum-scale=1, user-scalable=0">
              <style>
                body {
                  margin: 0;
                  padding: 0;
                  overflow: hidden; /* Disable scrolling */
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  height: 100vh;
                }
                svg {
                  max-width: 100%;
                  max-height: 100%;
                  display: block;
                  margin: auto;
                }
              </style>
            </head>
            <body>
              $currentSvg
            </body>
            </html>
            ''';
              _controller.loadHtmlString(htmlContent);
            }

            return Container(
                width: deviceWidth * 0.65,
                height: 400,
                padding: EdgeInsets.all(10),
                child: WebViewWidget(
                  controller: _controller,
                  gestureRecognizers: Set(),
                ),);
          });
    }

    htmlContent = '''
            <!DOCTYPE html>
            <html lang="en">
            <head>
              <meta name="viewport" content="width=device-width, initial-scale=0.7, maximum-scale=1, user-scalable=0">
              <style>
                body {
                  margin: 0;
                  padding: 0;
                  overflow: hidden; /* Disable scrolling */
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  height: 100vh;
                }
                svg {
                  max-width: 100%;
                  max-height: 100%;
                  display: block;
                  margin: auto;
                }
              </style>
            </head>
            <body>
              $currentSvg
            </body>
            </html>
            ''';

    _controller.loadHtmlString(htmlContent);
    //svg update
    return Container(
        width: deviceWidth * 0.65,
        height: 400,
        padding: EdgeInsets.all(10),
        child: Stack(
                  children: [
                    WebViewWidget(
                  controller: _controller,
                  gestureRecognizers: Set(),
                ),
                  rendering ? Center(child: CircularProgressIndicator(),) : SizedBox()
                  ],
                ));
  }

  Future<String?> fetchAndConvertToBase64(String imageUrl) async {
    try {
      // Mengambil gambar dari URL menggunakan HTTP GET
      final response = await http.get(Uri.parse(imageUrl));

      // Mengecek apakah response sukses
      if (response.statusCode == 200) {
        // Mengonversi byte data gambar ke Base64
        String base64Image = base64Encode(response.bodyBytes);
        return base64Image;
      } else {
        // Menangani error jika request gagal
        print('Gagal memuat gambar, status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Menangani error jika ada masalah dengan request HTTP
      print('Error: $e');
      return null;
    }
  }

  _featureWidget() {
    return Container(
      padding: EdgeInsets.all(5),
      width: deviceWidth * 0.35,
      child: ListView.builder(
          itemCount: svgFeatures.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.all(2),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: currentFeature != svgFeatures[index]
                      ? () {
                          setState(() {
                            currentFeature = svgFeatures[index];
                          });
                        }
                      : null,
                  child: Text(
                      textAlign: TextAlign.center,
                      svgFeatures[index].toString().replaceAll("-", " "))),
            );
          }),
    );
  }

  _sizeWidget() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.product.size.length,
        itemBuilder: (context, index) {
          final size = widget.product.size[index];
          final isSelected = _selectedSize == size;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSize = size; // Update ukuran yang dipilih
              });
            },
            child: Container(
              padding: EdgeInsets.all(5),
              width: 50,
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.red : Color(0xFFFFAAAA),
                border: isSelected
                    ? Border.all(color: Colors.black, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  textAlign: TextAlign.center,
                  size,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void goToDesignConfirmation(String htmlContent) {
    if (currentSvg.contains("none")) {
      Fluttertoast.showToast(
          msg: "Silakan kosumisasi desain kamu hingga selesai.");
      return;
    }
    if (_selectedSize == "" && _selectedSize.isEmpty) {
      Fluttertoast.showToast(msg: "Silakan pilih ukuran terlebih dahulu.");
      return;
    }

    if (widget.product == null) {
      Fluttertoast.showToast(msg: "Terjadi kesalahan, silakan coba lagi.");
      return;
    }

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DesignConfirmPage(currentSvg,htmlContent,
                currentFeatureColor, widget.product, _selectedSize)));
  }

  Future<String> getSizeGuide() async {
    ApiService apiService = ApiService();
    SizeGuideResponse response = await apiService.sizeGuide();

    if (response.error) {
      return "Terjadi Kesalahan";
    } else {
      return response.data!;
    }
  }

  sizeGuideWidget() {
    return FutureBuilder(
        future: getSizeGuide(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CachedNetworkImage(imageUrl: snapshot.data!);
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
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

String updateFillColorByIdWithPattern(
    String svgString, String elementId, String patternId) {
  final pattern =
      RegExp(r'<[^>]*id="' + elementId + r'"[^>]*>', multiLine: true);
  return svgString.replaceAllMapped(
    pattern,
    (match) {
      String element = match.group(0)!;

      if (element.contains('fill=')) {
        // Jika elemen sudah memiliki atribut `fill`, ubah nilainya dengan URL pattern
        element = element.replaceAll(
            RegExp(r'fill="[^"]*"'), 'fill="url(#$patternId)"');
      }
      return element;
    },
  );
}

String updateFillColorByIdWithColor(
    String svgString, String elementId, String newColor) {
  final pattern =
      RegExp(r'<[^>]*id="' + elementId + r'"[^>]*>', multiLine: true);
  return svgString.replaceAllMapped(
    pattern,
    (match) {
      String element = match.group(0)!;

      if (element.contains('fill=')) {
        // Jika elemen sudah memiliki atribut `fill`, ubah nilainya
        element =
            element.replaceAll(RegExp(r'fill="[^"]*"'), 'fill="$newColor"');
      } else {
        // Jika elemen tidak memiliki atribut `fill`, tambahkan atribut `fill`
        element = element.replaceFirst('>', ' fill="$newColor">');
      }
      return element;
    },
  );
}

Future<String> fetchSvg(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    // Jika berhasil, simpan data SVG ke dalam string
    return response.body;
  } else {
    // Handle error jika gagal
    print('Failed to load SVG');
    return "";
  }
}
