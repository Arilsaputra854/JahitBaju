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
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/home_view_model.dart';
import 'package:jahit_baju/views/cart_screen/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';
import 'package:http/http.dart' as http;

class ProductScreen extends StatefulWidget {
  final Product product;
  const ProductScreen(this.product, {super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  var _selectedSize = "";
  var deviceWidth;

  var currentSvg = "";

  var updatedSvg;

  late bool isFavorited;
  late int favoriteId;

  List<String> svgColor = [];
  List<String> svgFeatures = [];

  String? currentColor;
  String? currentFeature;


  @override
  void initState() {
    isFavorited = false;
    if(widget.product.type == Product.CUSTOM){
      svgColor = widget.product.colors!;
      svgFeatures = widget.product.features!;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
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
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () => addToCart(),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 5, // Jarak antara ikon dan teks
                          children: [
                            Icon(
                              Icons.shopping_bag,
                              color: Colors.black,
                            ),
                            Text(
                              "Tambah ke Keranjang",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap:
                                  true, // Agar teks membungkus jika tidak cukup ruang
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
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {},
                        child: Text(
                          "Beli Sekarang",
                          style: TextStyle(
                            color: Colors.white,
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
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Selanjutnya",
                      style: TextStyle(
                        color: Colors.white,
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
                "Pilih Ukuran",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Container(
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
              )
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
                Container(
                  width: 150,
                  child: ListView.builder(
                      itemCount: svgFeatures.length,
                      itemBuilder: (context, index) {
                        
                        return ElevatedButton(
                            onPressed: currentFeature != svgFeatures[index]
                                ? () {
                                    setState(() {
                                      currentFeature = svgFeatures[index];
                                    });
                                  }
                                : null,
                            child: Text(
                                textAlign: TextAlign.center,
                                svgFeatures[index]
                                    .toString()
                                    .replaceAll("-", " ")));
                      }),
                ),
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
                    IconButton(
                        onPressed: () {
                          addProductFavorite(widget.product);
                        },
                        icon: isFavorited
                            ? Icon(Icons.favorite)
                            : Icon(Icons.favorite_border))
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
                  "Pilih Ukuran",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    height: 60,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.product.size.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 50,
                            height: 50,
                            margin: EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFFAAAA)),
                            child: Center(
                              child: Text(widget.product.size[index],
                                  style: TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center),
                            ),
                          );
                        })),
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
    ApiService apiService = ApiService();

    if (_selectedSize != "" && _selectedSize.isNotEmpty) {
      var msg = await apiService.cartAdd(widget.product, 1, _selectedSize);
      Fluttertoast.showToast(msg: msg);

      context.read<HomeViewModel>().refresh();
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
            height: deviceWidth * 0.1,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: svgColor.length,
              itemBuilder: (context, index) {
                print(svgColor[index]);
                return InkWell(
                    onTap: () {
                      if (currentFeature != "") {
                        setState(() {
                          currentColor = svgColor[index];
                          updatedSvg = updateFillColorById(currentSvg,
                              currentFeature!, currentColor!);
                          currentSvg = updatedSvg;
                        });
                      }
                    },
                    child: svgColor[index].contains("https")? 
                    Container(
                      clipBehavior: Clip.hardEdge,
                      width: deviceWidth * 0.1,
                      height: deviceWidth * 0.1,
                      margin:
                          EdgeInsets.symmetric(horizontal: deviceWidth * 0.01),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey
                      ),
                      child: Image.network(svgColor[index],fit: BoxFit.cover,),
                    ) : Container(
                      width: deviceWidth * 0.1,
                      height: deviceWidth * 0.1,
                      margin:
                          EdgeInsets.symmetric(horizontal: deviceWidth * 0.01),
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

  customPreview() {
    //dari server
    if(currentSvg == ""){
      return FutureBuilder(
        future: fetchSvg(widget.product.imageUrl.first),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return CircularProgressIndicator();
          }
          if(snapshot.hasData){
              currentSvg = snapshot.data!;
          }
          return Container(
              width: 250,
              height: 400,
              padding: EdgeInsets.all(10),
              child: SvgPicture.string(currentSvg));
        });
    }
    //svg update
    return Container(
        width: 250,
        height: 400,
        padding: EdgeInsets.all(10),
        child: SvgPicture.string(currentSvg));
  }
}

String updateFillColorById(
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
