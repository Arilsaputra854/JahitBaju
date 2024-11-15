import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/api/api_service.dart';
import 'package:jahit_baju/model/order.dart';
import 'package:jahit_baju/model/order_item.dart';
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/views/cart_screen/cart_screen.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';

class ProductScreen extends StatefulWidget {
  final Product product;
  const ProductScreen(this.product, {super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  var deviceWidth;

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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0)),
                        backgroundColor: Colors.white, // Latar belakang merah
                        padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10), // Padding agar tombol lebih besar
                      ),
                      onPressed: () =>addToCart(),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_bag,
                            color: Colors.black,
                          ),
                          SizedBox(width: 3),
                          Text(
                            "Tambah ke keranjang",
                            style: TextStyle(
                              color: Colors.black, // Warna teks putih
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)),
                      backgroundColor: Colors.red, // Latar belakang merah
                      padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 30), // Padding agar tombol lebih besar
                    ),
                    onPressed: () {},
                    child: Text(
                      "Beli Sekarang",
                      style: TextStyle(
                        color: Colors.white, // Warna teks putih
                        fontWeight: FontWeight.bold,
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
                      borderRadius: BorderRadius.circular(0)),
                  backgroundColor: Colors.red, // Latar belakang merah
                  padding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 30), // Padding agar tombol lebih besar
                ),
                onPressed: () {},
                child: Text(
                  "Selanjutnya",
                  style: TextStyle(
                    color: Colors.white, // Warna teks putih
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
    );
  }

  showRTW() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          child: Container(
            color: Colors.black,
            height: 400,
            width: deviceWidth,
            child: Image.network(
              alignment: Alignment(1, -0.3),
              widget.product.imageUrl[0],
              fit: BoxFit.cover,
            ),
          ),
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
                    "IDR ${widget.product.price.toString()}",
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
                  IconButton(
                      onPressed: () {}, icon: Icon(Icons.favorite_border))
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
                              shape: BoxShape.circle, color: Color(0xFFFFAAAA)),
                          child: Center(
                            child: Text(
                              widget.product.size[index],
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        );
                      })),
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
                        onPressed: () {}, icon: Icon(Icons.favorite_border))
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
                              child: Text(
                                widget.product.size[index],
                                style: TextStyle(fontSize: 15),
                              ),
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
  
  addToCart() {
    var success = true;
    if(success){
      goToCartScreen();
    }
  }
}

customPreview() {
  return Container(
    width: 300,
    padding: EdgeInsets.all(10),
    color: Colors.red
    ,
    child:  Stack(
      alignment: Alignment.center,
    children: [
       
      Positioned(
        left: 20,
        child: 
      SvgPicture.asset("assets/coat/clutch-coat-badan-depan-kiri.svg",color: const Color.fromARGB(255, 38, 1, 142)),),
      Positioned(
        child: 
      SvgPicture.asset("assets/coat/clutch-coat-badan-depan-kanan.svg",color: const Color.fromARGB(255, 10, 49, 188)),),
      Positioned(        
        left: 50,
        top: -40,    
        child: SvgPicture.asset("assets/coat/clutch-coat-kerah.svg",color: Colors.white,),
       ),
    ],
  )
  );
}


