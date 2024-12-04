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
import 'package:jahit_baju/views/cart_screen/cart_screen.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';

class ProductScreen extends StatefulWidget {
  final Product product;
  const ProductScreen(this.product, {super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  var _selectedSize = "";
  var deviceWidth;

  late bool isFavorited;
  late int favoriteId;

  @override
  void initState() {
    isFavorited = false;
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
                Column(
                  children: [
                    Text("Bagian"),
                    ElevatedButton(onPressed: () {}, child: Text("Kerah Kiri")),
                    ElevatedButton(
                        onPressed: () {}, child: Text("Kerah Kanan")),
                    ElevatedButton(onPressed: () {}, child: Text("Kiri Depan")),
                    ElevatedButton(
                        onPressed: () {}, child: Text("Kanan Depan")),
                  ],
                ),
                //customPreview()
              ],
            )),
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

        setState(() {
          
        });
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
}

customPreview() {
  return Container(
      width: 300,
      padding: EdgeInsets.all(10),
      color: Colors.red,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 20,
            child: SvgPicture.asset(
                "assets/coat/clutch-coat-badan-depan-kiri.svg",
                color: const Color.fromARGB(255, 38, 1, 142)),
          ),
          Positioned(
            child: SvgPicture.asset(
                "assets/coat/clutch-coat-badan-depan-kanan.svg",
                color: const Color.fromARGB(255, 10, 49, 188)),
          ),
          Positioned(
            left: 50,
            top: -40,
            child: SvgPicture.asset(
              "assets/coat/clutch-coat-kerah.svg",
              color: Colors.white,
            ),
          ),
        ],
      ));
}
