import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/cache/cache.dart';
import 'package:jahit_baju/data/model/designer.dart';
import 'package:jahit_baju/data/model/look.dart';
import 'package:jahit_baju/data/model/look_texture.dart';
import 'package:jahit_baju/data/model/texture.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/custom_product_view_model.dart';
import 'package:jahit_baju/views/product_screen/design_confirm_page.dart';
import 'package:jahit_baju/views/shipping_screen/shipping_screen.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomProductScreen extends StatefulWidget {
  final Look look;
  final Designer designer;
  const CustomProductScreen(this.designer, this.look, {super.key});

  @override
  State<CustomProductScreen> createState() => _CustomProductScreenState();
}

class _CustomProductScreenState extends State<CustomProductScreen> {
  late WebViewController _controller;

  var deviceWidth;
  var updatedSvg;

  List<LookTexture> svgColor = [];
  List<String> svgFeatures = [];

  CacheHelper cache = CacheHelper();

  late String htmlContent;

  Map<String, String> base64Textures = {};

  Logger log = Logger();

  @override
  initState() {
    _controller = WebViewController();
    _controller.enableZoom(false);

    final viewModel =
        Provider.of<CustomProductViewModel>(context, listen: false);
    viewModel.resetData();

    viewModel.getNoteProduct(Product.CUSTOM);
    viewModel.getCareGuide();
    viewModel.getSizeGuide();
    viewModel.setLook(widget.look);
    svgColor = widget.look.textures ?? [];
    svgFeatures = widget.look.features ?? [];
    fetchAllAndConvertToBase64();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    return Consumer<CustomProductViewModel>(
      builder: (context, viewModel, child) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  "Kostum Produk",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              body: SingleChildScrollView(child: showCustom(viewModel)),
              bottomNavigationBar: _bottomNavigationWidget(viewModel),
            ),
            if (viewModel.loading) loadingWidget()
          ],
        );
      },
    );
  }

  showCustom(CustomProductViewModel viewModel) {
    return Column(
      children: [
        Container(
            height: 300.h,
            child: Row(
              children: [
                _featureWidget(viewModel),
                customPreview(viewModel),
              ],
            )),
        _textureWidget(viewModel),
        Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.look?.name ?? "Nama Produk",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 25.sp),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "${viewModel.look?.sold ?? 0} Terjual | ${viewModel.look?.seen ?? 0} Favorit\n${viewModel.look?.seen ?? 0} Orang melihat produk ini",
                  style: TextStyle(
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.designer.name,
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
                _descriptionWidget(viewModel),
                SizedBox(
                  height: 20,
                ),
                sizeGuideWidget(viewModel),
                SizedBox(
                  height: 20,
                ),
                _careGuideWidget(viewModel),
                _noteWidget(viewModel),
                SizedBox(
                  height: 20,
                ),
                _sizeWidget(viewModel),
                SizedBox(
                  height: 10,
                ),
              ],
            ))
      ],
    );
  }

  _textureWidget(CustomProductViewModel viewModel) {
    if (svgColor.isNotEmpty &&
        viewModel.currentFeature != null &&
        viewModel.currentSVG != null) {
      return Container(
        padding: EdgeInsets.all(2),
        color: Colors.white,
        height: deviceWidth * 0.1,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: svgColor.length,
          itemBuilder: (context, index) {
            return InkWell(
                onLongPress: () {
                  _previewTextureDetails(svgColor[index].texture);
                },
                onTap: () async {
                  try {
                    if (viewModel.currentFeature != "" &&
                        viewModel.currentSVG != null) {
                      if (svgColor[index].texture.hex != null) {
                        viewModel.setCurrentColor(svgColor[index].texture.hex!);
                      } else if (svgColor[index].texture.urlTexture != null) {
                        viewModel.setCurrentColor(
                            svgColor[index].texture.urlTexture!);
                      }

                      if (svgColor[index].texture.urlTexture != null) {
                        // Ambil dan konversi gambar ke Base64
                        String? base64Image =
                            base64Textures[svgColor[index].textureId];

                        if (base64Image != null) {
                          updatedSvg = addPatternToSvg(viewModel.currentSVG!,
                              "base64Image", viewModel.currentFeature!);
                          updatedSvg = addPatternToSvg(viewModel.currentSVG!,
                              base64Image, viewModel.currentFeature!);
                        }
                      } else if (svgColor[index].texture.hex != null) {
                        // Jika tidak ada URL gambar, lakukan perubahan warna biasa
                        updatedSvg = updateFillColorByIdWithColor(
                            viewModel.currentSVG!,
                            viewModel.currentFeature!,
                            viewModel.currentColor!);
                      }

                      viewModel.currentFeatureColor[viewModel.currentFeature!] =
                          viewModel.currentColor!;
                      viewModel.setCurrentSVG(updatedSvg);
                    }
                  } catch (e) {
                    Fluttertoast.showToast(
                        msg:
                            "Silakan pilih bagian yang mau di masukkan warna atau ulos.");
                  }
                },
                child: svgColor[index].texture.urlTexture != null
                    ? Container(
                        clipBehavior: Clip.hardEdge,
                        width: deviceWidth * 0.1,
                        height: deviceWidth * 0.1,
                        margin: EdgeInsets.symmetric(
                            horizontal: deviceWidth * 0.01),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: CachedNetworkImage(
                          imageUrl: svgColor[index].texture.urlTexture!,
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
                          color: Color(int.parse(svgColor[index]
                              .texture
                              .hex!
                              .replaceFirst('#', '0xFF'))),
                        ),
                      ));
          },
        ),
      );
    } else {
      return SizedBox();
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

  customPreview(CustomProductViewModel viewModel) {
    //dari server
    if (viewModel.currentSVG == null) {
      viewModel.fetchSvg();
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
              ${viewModel.currentSVG}
            </body>
            </html>
            ''';
    _controller.loadHtmlString(htmlContent);
    //svg update
    return Container(
        width: 240.w,
        height: 300.h,
        padding: EdgeInsets.all(10),
        child: WebViewWidget(
          controller: _controller,
          gestureRecognizers: Set(),
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
          log.d(
              'Fetch and Convert to Base64: Gagal memuat gambar, status code: ${response.statusCode}');
          Fluttertoast.showToast(
              msg: "Tidak dapat memuat tekstur kain, silakan coba lagi nanti.");
          return null;
        }
      } catch (e, stackTrace) {
        FirebaseCrashlytics.instance.recordError(e, stackTrace);
        // Menangani error jika ada masalah dengan request HTTP
        log.d('Fetch and Convert to Base64: Terjadi kesalahan ${e}');
        Fluttertoast.showToast(msg: ApiService.SOMETHING_WAS_WRONG);
        return null;
      }
    } else {
      return base64Textures[imageUrl];
    }
  }

  Future<void> fetchAllAndConvertToBase64() async {
    Map<String, String>? cachedTextures = await cache.getBase64Map();
    if (cachedTextures != null && cachedTextures.isNotEmpty) {
      setState(() {
        base64Textures = cachedTextures;
      });
      log.d(
          "Base64 textures loaded from cache : ${json.encode(cachedTextures)}");
    } else {
      log.d("start fetching base64 texture from server");
      for (LookTexture texture in svgColor) {
        if (texture.texture.urlTexture != null) {
          if (base64Textures[texture.textureId] == null) {
            try {
              final response =
                  await http.get(Uri.parse(texture.texture.urlTexture!));

              if (response.statusCode == 200) {
                String base64Image = base64Encode(response.bodyBytes);
                log.d("finish fetch ${base64Textures[texture.textureId]}");
                setState(() {
                  base64Textures[texture.textureId] = base64Image;
                });
              } else {
                // Menangani error jika request gagal
                log.d(
                    'Fetch and Convert to Base64: Gagal memuat gambar, status code: ${response.statusCode}');
                return null;
              }
            } catch (e, stackTrace) {
              FirebaseCrashlytics.instance.recordError(e, stackTrace);
              // Menangani error jika ada masalah dengan request HTTP
              log.d('Fetch and Convert to Base64: Terjadi kesalahan ${e}');
              return null;
            }
          }
        }
      }

      await cache.saveBase64Map(base64Textures);

      log.d("Base64 textures saved to cache");
      log.d("finish fetching all texture.");
    }
  }

  _featureWidget(CustomProductViewModel viewModel) {
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
                  onPressed: viewModel.currentFeature != svgFeatures[index]
                      ? () {
                          viewModel.setCurrentFeature(svgFeatures[index]);
                        }
                      : null,
                  child: Text(
                      style: TextStyle(fontSize: 12.sp),
                      textAlign: TextAlign.center,
                      svgFeatures[index].toString().replaceAll("-", " "))),
            );
          }),
    );
  }

  _sizeWidget(CustomProductViewModel viewModel) {
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
        if (viewModel.look != null)
          Container(
            margin: EdgeInsets.only(bottom: 10),
            height: 50.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.look?.size?.length ?? 0,
              itemBuilder: (context, index) {
                final size = viewModel.look!.size![index];
                final isSelected = viewModel.selectedSize == size;

                return GestureDetector(
                  onTap: () {
                    viewModel.setSelectedSize(size);
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

  void goToDesignConfirmation(
      String htmlContent, CustomProductViewModel viewModel) {
    if (viewModel.currentSVG != null) {
      if (viewModel.currentSVG!.contains("none")) {
        Fluttertoast.showToast(
            msg: "Silakan kostumisasi desain kamu hingga selesai.");
        return;
      }
      if (viewModel.selectedSize == null) {
        Fluttertoast.showToast(msg: "Silakan pilih ukuran terlebih dahulu.");
        return;
      }

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DesignConfirmPage(
                  viewModel.currentSVG!,
                  htmlContent,
                  viewModel.currentFeatureColor,
                  widget.look,
                  viewModel.selectedSize!)));
    }
  }

  sizeGuideWidget(CustomProductViewModel viewModel) {
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
        if (viewModel.sizeGuide != null)
          CachedNetworkImage(
            imageUrl: viewModel.sizeGuide!,
            errorWidget: (context, url, error) {
              log.d("Size Guide : cannot load image, error ${error}");
              return Icon(Icons.image_not_supported);
            },
          )
        else
          Center(
            child: Icon(Icons.image_not_supported),
          )
      ],
    );
  }

  _careGuideWidget(CustomProductViewModel viewModel) {
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
        Text(
          viewModel.careGuides ?? "",
          style: TextStyle(
            fontSize: 14.sp,
          ),
        )
      ],
    );
  }

  _noteWidget(CustomProductViewModel viewModel) {
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
        Text(
          viewModel.productNotes ?? "",
          style: TextStyle(
            fontSize: 14.sp,
          ),
        )
      ],
    );
  }

  _bottomNavigationWidget(CustomProductViewModel viewModel) {
    if (viewModel.currentSVG != null) {
      return Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
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
                        } catch (e, stackTrace) {
                          FirebaseCrashlytics.instance
                              .recordError(e, stackTrace);
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
                          onPressed: viewModel.currentSVG!.contains("none")
                              ? null
                              : () {
                                  goToDesignConfirmation(
                                      htmlContent, viewModel);
                                },
                          child: Text(
                            "Selanjutnya",
                            style: TextStyle(
                              color: viewModel.currentSVG!.contains("none")
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          )))
                ],
              )),
        ],
      );
    } else {
      return Container();
    }
  }

  _descriptionWidget(CustomProductViewModel viewModel) {
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
          viewModel.look?.description ?? "Deskripsi",
          style: TextStyle(
            fontSize: 14.sp,
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
        if (widget.look.materials != null)
          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.look.materials!.length,
            itemBuilder: (context, index) {
              return Text(
                "-${widget.look.materials![index]}",
                style: TextStyle(
                  fontSize: 14.sp,
                ),
              );
            },
          ),
      ],
    );
  }

  _previewTextureDetails(TextureLook texture) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          contentPadding: EdgeInsets.all(16.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              texture.urlTexture != null
                  ? Image.network(
                      // Bisa diganti Image.asset jika gambar lokal
                      texture.urlTexture!,
                      width: 150.w,
                      height: 150.w,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 150.w,
                      height: 150.w,
                      decoration: BoxDecoration(
                        color: Color(
                            int.parse(texture.hex!.replaceFirst('#', '0xFF'))),
                      ),
                    ),
              SizedBox(height: 16),
              Text(
                texture.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                texture.description ?? "Tidak ada deskripsi.",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text("Tutup"),
            ),
          ],
        );
      },
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
