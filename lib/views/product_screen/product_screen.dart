import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/model/favorite.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/source/remote/response/favorite_response.dart';
import 'package:jahit_baju/data/source/remote/response/product_note_response.dart';
import 'package:jahit_baju/data/source/remote/response/product_response.dart';
import 'package:jahit_baju/data/source/remote/response/product_term_response.dart';
import 'package:jahit_baju/data/source/remote/response/size_guide_response.dart';
import 'package:jahit_baju/helper/app_color.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/views/cart_screen/cart_screen.dart';
import 'package:jahit_baju/views/product_screen/design_confirm_page.dart';
import 'package:jahit_baju/views/shipping_screen/shipping_screen.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../data/source/remote/response/care_guide_response.dart';

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

  late ApiService apiService;

  List<String> svgColor = [];
  List<String> svgFeatures = [];

  Map<String, String> currentFeatureColor = {};

  late String htmlContent;

  String? currentColor;
  String? currentFeature;

  Logger log = Logger();

  bool purchaseLoading = false;

  Map<String, String> base64Textures = {};

  @override
  initState() {
    apiService = ApiService(context);
    isFavorited = false;

    if (widget.product.type == Product.CUSTOM) {
      _controller = WebViewController();
      _controller.enableZoom(false);

      svgColor = widget.product.colors!;
      svgFeatures = widget.product.features!;
      fetchAllAndConvertToBase64();
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
            : "Kostum Produk",style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: SingleChildScrollView(
          child: widget.product.type == Product.READY_TO_WEAR
              ? showRTW()
              : showCustom()),
      bottomNavigationBar: _bottomNavigationWidget(),
    );
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: AspectRatio(
                        aspectRatio: 4 / 5,
                        child: CachedNetworkImage(
                          imageUrl: widget.product.imageUrl.first,
                          errorWidget: (context, url, error) {
                            return Icon(Icons.image_not_supported);
                          },
                          alignment: const Alignment(1, -0.3),
                          fit: BoxFit.cover,
                        )),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        '${widget.product.imageUrl.length} Foto',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          onTap: () {
            SwipeImageGallery(
              hideStatusBar: false,
              context: context,
              itemBuilder: (context, indexImage) {
                return CachedNetworkImage(
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    return Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                    );
                  },
                  imageUrl: widget.product.imageUrl[indexImage],
                );
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
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
                      children: widget.product.category!.map((category) {
                        return Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
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
                      fontSize: 16.sp,
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
                      fontSize: 15.sp,
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
              _materialWidget(),
              SizedBox(
                height: 20,
              ),
              _descriptionWidget(),
              SizedBox(
                height: 20,
              ),
              sizeGuideWidget(),
              SizedBox(
                height: 20,
              ),
              _careGuideWidget(),
              SizedBox(
                height: 20,
              ),
              _noteWidget(),
              SizedBox(
                height: 20,
              ),
              _sizeWidget(),
              SizedBox(
                height: 10,
              ),
              _tagsWidget(),
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
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 25.sp),
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
                        fontSize: 15.sp,
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
                  height: 10,
                ),
                Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.product.designerCategory,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                SizedBox(
                  height: 10,
                ),
                 _materialWidget(),
              SizedBox(
                height: 20,
              ),
              _descriptionWidget(),
              SizedBox(
                height: 20,
              ),
              sizeGuideWidget(),
              SizedBox(
                height: 20,
              ),
              _careGuideWidget(),
              SizedBox(
                height: 20,
              ),
              _noteWidget(),
              SizedBox(
                height: 20,
              ),
              _sizeWidget(),
              SizedBox(
                height: 10,
              ),
              _tagsWidget(),
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
    ApiService apiService = ApiService(context);

    ProductResponse productResponse =
        await apiService.productsGetById(widget.product.id);
    if (productResponse.error) {
      Fluttertoast.showToast(
          msg:
              productResponse.message ?? "Terjadi kesalahan, Coba lagi nanti.");
    } else {
      if (productResponse.product != null) {
        if (productResponse.product!.stock > 0) {
          if (_selectedSize != "" && _selectedSize.isNotEmpty) {
            var msg = await apiService.cartAdd(
                widget.product, 1, _selectedSize, null);
            setState(() {
              purchaseLoading = false;
            });
            Fluttertoast.showToast(msg: msg);
          } else {
            Fluttertoast.showToast(msg: "Silakan pilih ukuran terlebih dahulu");
          }
        } else {
          Fluttertoast.showToast(msg: "Maaf, Stok produk ini telah habis");
          Navigator.pop(context);
        }
      } else {
        Fluttertoast.showToast(msg: "Maaf, Produk tidak ditemukan");
      }
    }
  }

  Future getFavoriteStatus() async {
    ApiService apiService = ApiService(context);
    List<Favorite> favorites = await apiService.favoriteGet(context);

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
    ApiService apiService = ApiService(context);

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
    if (svgColor.isNotEmpty) {
      return Container(
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
                              currentSvg, "base64Image", currentFeature!);
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
                        currentFeatureColor[currentFeature!] = currentColor!;
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
      );
    }
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
    // Regex untuk menemukan dan menghapus pattern yang sudah ada
    final patternRegex = RegExp(
      r'<pattern id="' + patternId + r'".*?</pattern>',
      dotAll: true,
    );

    // Hapus pattern lama jika ada
    var updatedSvg = svg.replaceAll(patternRegex, '');

    // Definisi pola baru
    final patternDefinition = '''
    <defs>
      <pattern id="$patternId" patternUnits="userSpaceOnUse" width="200" height="500">
        <image href="data:image/png;base64,$base64" x="0" y="0" width="200" height="500" />
      </pattern>
    </defs>
  ''';

    // Masukkan pattern sebelum tag <g>
    updatedSvg = updatedSvg.replaceFirst(RegExp(r'<g'), '$patternDefinition<g');

    // Ganti fill pada elemen dengan ID yang sesuai
    var updatedSvgWithPattern =
        updateFillColorByIdWithPattern(updatedSvg, patternId, patternId);

    return updatedSvgWithPattern;
  }

  customPreview() {
    //dari server
    if (currentSvg == "") {
      return FutureBuilder(
          future: fetchSvg(widget.product.imageUrl.first),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                  width: 260.w,
                  height: 400.h,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ));
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
              ),
            );
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

    log.d(currentSvg);
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
            rendering
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SizedBox()
          ],
        ));
  }

  Future<String?> fetchAndConvertToBase64(String imageUrl) async {
    if (base64Textures[imageUrl] == null) {
      try {
        // Mengambil gambar dari URL menggunakan HTTP GET
        final response = await http.get(Uri.parse(imageUrl));

        // Mengecek apakah response sukses
        if (response.statusCode == 200) {
          // Mengonversi byte data gambar ke Base64

          String base64Image = base64Encode(response.bodyBytes);
          base64Textures[imageUrl] = base64Image;
          return base64Textures[imageUrl];
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
    } else {
      return base64Textures[imageUrl];
    }
  }

  Future<void> fetchAllAndConvertToBase64() async {
    log.d("start fetching all texture");
    for (String svg in svgColor) {
      if (svg.contains("https")) {
        if (base64Textures[svg] == null) {
          try {
            // Mengambil svg dari URL menggunakan HTTP GET
            final response = await http.get(Uri.parse(svg));

            // Mengecek apakah response sukses
            if (response.statusCode == 200) {
              // Mengonversi byte data gambar ke Base64

              String base64Image = base64Encode(response.bodyBytes);
              setState(() {
                base64Textures[svg] = base64Image;
                log.d("finish fetch ${base64Textures[svg]}");
              });
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
      }
    }

    log.d("finish fetching all texture");
  }

  _featureWidget() {
    return Container(
      padding: EdgeInsets.all(5),
      width: 120.w,
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
                  child: Text(style: TextStyle(fontSize: 12.sp),
                      textAlign: TextAlign.center,
                      svgFeatures[index].toString().replaceAll("-", " "))),
            );
          }),
    );
  }

  _sizeWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          "PILIH UKURAN",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          height: 50.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.product.size.length,
            itemBuilder: (context, index) {
              final size = widget.product.size[index];
              final isSelected = _selectedSize == size;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    purchaseLoading = false;
                    _selectedSize = size; // Update ukuran yang dipilih
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(5),
                  width: 50.h,
                  height: 50.h,
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
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
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
            builder: (context) => DesignConfirmPage(currentSvg, htmlContent,
                currentFeatureColor, widget.product, _selectedSize)));
  }

  Future<String> getSizeGuide() async {
    ApiService apiService = ApiService(context);
    SizeGuideResponse response = await apiService.sizeGuide();

    if (response.error) {
      return "Terjadi Kesalahan";
    } else {
      return response.data!;
    }
  }

  Future<String> getNoteProduct(int type) async {
    ApiService apiService = ApiService(context);
    ProductNoteResponse response = await apiService.getNoteProduct(type);

    if (response.error) {
      return "Terjadi Kesalahan";
    } else {
      return response.data!;
    }
  }

  Future<String> getCareGuide() async {
    ApiService apiService = ApiService(context);
    CareGuideResponse response = await apiService.getCareGuide();

    if (response.error) {
      return "Terjadi Kesalahan";
    } else {
      return response.data!;
    }
  }

  sizeGuideWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          "PANDUAN UKURAN",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        FutureBuilder(
            future: getSizeGuide(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData) {
                return CachedNetworkImage(
                  imageUrl: snapshot.data!,
                  errorWidget: (context, url, error) {
                    return Icon(Icons.image_not_supported);
                  },
                );
              } else {
                return Center(
                  child: Icon(Icons.image_not_supported),
                );
              }
            })
      ],
    );
  }

  _careGuideWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          "PANDUAN PERAWATAN",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        FutureBuilder(
            future: getCareGuide(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData && snapshot.data != null) {
                return Text(
                  snapshot.data!,
                  style: TextStyle(
                    fontSize: 12.sp,
                  ),
                );
              } else {
                return Center(
                  child: Icon(Icons.image_not_supported),
                );
              }
            })
      ],
    );
  }

  _noteWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          "CATATAN",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        FutureBuilder(
            future: widget.product.type == Product.READY_TO_WEAR
                ? getNoteProduct(Product.READY_TO_WEAR)
                : getNoteProduct(Product.CUSTOM),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData && snapshot.data != null) {
                return Text(
                  snapshot.data!,
                  style: TextStyle(
                    fontSize: 12.sp,
                  ),);
              } else {
                return Center(
                  child: Icon(Icons.image_not_supported),
                );
              }
            })
      ],
    );
  }

  _bottomNavigationWidget() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        widget.product.type == Product.READY_TO_WEAR
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
                        onPressed: purchaseLoading ? null : () => addToCart(),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 5, // Jarak antara ikon dan teks
                          children: [
                            Icon(
                              Icons.shopping_bag,
                              color: purchaseLoading
                                  ? const Color.fromARGB(255, 95, 92, 92)
                                  : Colors.black,
                            ),
                            Text(
                              "Tambah ke Keranjang",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: purchaseLoading
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
                          backgroundColor:
                              purchaseLoading ? Colors.grey : Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          buyNow(context, _selectedSize, widget.product);
                        },
                        child: Text(
                          "Beli Sekarang",
                          style: TextStyle(
                                fontSize: 12.sp,
                            color: purchaseLoading
                                ? const Color.fromARGB(255, 95, 92, 92)
                                : Colors.white,
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
                width: deviceWidth,
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        onPressed: () async {
                          Uri url = Uri.parse("http://wa.me/+6281284844428");
                          try {
                            await launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          } catch (e) {
                            Fluttertoast.showToast(
                                msg:
                                    "Terjadi kesalahan, silakan coba lagi nanti.");
                          }
                        },
                        child: Icon(Icons.chat)),
                    SizedBox(width: 10),
                    Expanded(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              backgroundColor: Colors.red,
                              disabledBackgroundColor: Colors.grey,
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                            ),
                            onPressed: currentSvg.contains("none")
                                ? null
                                : () {
                                    goToDesignConfirmation(htmlContent);
                                  },
                            child: Text(
                              "Selanjutnya",
                              style: TextStyle(
                                color: currentSvg.contains("none")
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )))
                  ],
                )),
        widget.product.stock <= 0
            ? Positioned.fill(
                child: Container(
                    padding: EdgeInsets.all(20),
                    color: const Color.fromARGB(213, 255, 255, 255),
                    child: Center(
                      child: Text(
                        "Stok Habis",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp
                        ),
                      ),
                    )),
              )
            : SizedBox()
      ],
    );
  }

  _descriptionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          "DESKRIPSI",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          widget.product.description,
          style: TextStyle(
            fontSize: 15.sp,
          ),
        )
      ],
    );
  }

  _materialWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          "MATERIAL",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        if (widget.product.materials != null)
          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.product.materials!.length,
            itemBuilder: (context, index) {
              return Text(
                "-${widget.product.materials![index]}",
                style: TextStyle(
                  fontSize: 15.sp,
                ),
              );
            },
          ),
      ],
    );
  }
  
  _tagsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
                "Tags",
                style: TextStyle(                  
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Wrap(
                spacing: 5, // Jarak horizontal antar tag
                runSpacing: 5, // Jarak vertikal antara baris tag
                children: widget.product.tags!.map((tag) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColor.tag,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                      ),
                    ),
                  );
                }).toList(),
              ),],);
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
