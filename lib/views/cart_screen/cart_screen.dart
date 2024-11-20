import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:jahit_baju/api/api_service.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/model/cart.dart';
import 'package:jahit_baju/model/order.dart';
import 'package:jahit_baju/model/order_item.dart';
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/views/product_screen/product_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var deviceWidth;

  @override
  Widget build(BuildContext context) {
    

    loadOrderData();


    deviceWidth = MediaQuery.of(context).size.width;
    var deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: Text("Cart"),
          centerTitle: true,
        ),
        bottomNavigationBar: Container(
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
              "Checkout",
              style: TextStyle(
                color: Colors.white, // Warna teks putih
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: FutureBuilder(future: loadOrderData(), builder: (context, snapshot){
          if(snapshot.hasData){
            return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: deviceWidth,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Siap Pakai",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 25),
                          ),
                          SizedBox(height: 10),
                          FutureBuilder<List<dynamic>>(future: _getCartItems(snapshot.data!, Product.READY_TO_WEAR), builder: (context, snapshot){                            
                            print(snapshot.data);
                            if(snapshot.hasData){
                              return Container(
                                  child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount:
                                      snapshot.data!
                                          .length,
                                  itemBuilder: (context, index) {
                                    final item = snapshot.data![index];

                                    if (item is String) {
                                      // Jika item adalah String, tampilkan sebagai tanggal
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      );
                                    } else if (item is OrderItem) {
                                      // Jika item adalah OrderItem, tampilkan detail produk
                                      return _buildOrderItem(item);
                                    }
                                    return Container();
                                  },
                                ));
                            }
                            return Container(
                                  height: deviceHeight * 0.2,
                                  child: Center(
                                    child: Text("Tidak ada data"),
                                  ),
                                );
                          }),
                          SizedBox(height: 10),
                          Text(
                            "Custom Produk",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 25),
                          ),
                          SizedBox(height: 10),
                          FutureBuilder<List<dynamic>>(future: _getCartItems(snapshot.data!, Product.CUSTOM), builder: (context, snapshot){
                            if(snapshot.hasData){
                              return snapshot.data!.isNotEmpty
                              ? Container(
                                  child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount:
                                      snapshot.data!
                                          .length,
                                  itemBuilder: (context, index) {
                                    final item = snapshot.data![index];

                                    if (item is String) {
                                      // Jika item adalah String, tampilkan sebagai tanggal
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      );
                                    } else if (item is OrderItem) {
                                      // Jika item adalah OrderItem, tampilkan detail produk
                                      return _buildOrderItem(item);
                                    }
                                    return Container();
                                  },
                                ))
                              : Container(
                                  height: deviceHeight * 0.2,
                                  child: Center(
                                    child: Text("Tidak ada data"),
                                  ),
                                );
                            }
                            return Placeholder();
                          }),
                          SizedBox(height: 30),
                          Container(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Siap pakai",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Text(
                                      "Rp 0.00",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Custom",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Text(
                                      "Rp 0.00",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    Text(
                                      "Rp 0.00",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
              
          }else{
            return Placeholder();
          }
        }));
  }

  Widget _buildOrderItem(dynamic item) {
    if (item is String) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          item,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    } else if (item is OrderItem) {
      return Container(
          height: 200,
          width: deviceWidth,
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: InkWell(
              onTap: () {},
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(item.quantity.toString() + " x "),
                    ),
                    Container(
                        child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8)),
                            child: AspectRatio(
                                aspectRatio: 4 / 5,
                                child: FutureBuilder(
                                    future: getProductById(item.productId),
                                    builder: (context, snapshot) {
                                      return snapshot.data!.type ==
                                              Product.READY_TO_WEAR
                                          ? Image.network(
                                              snapshot.data!.imageUrl.first,
                                              fit: BoxFit.cover,
                                            )
                                          : SvgPicture.network(
                                              snapshot.data!.imageUrl.first);
                                    })))),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<Product>(
                                    future: getProductById(item.productId),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Text(
                                          snapshot.data!.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        );
                                      }
                                      return Container();
                                    }),
                                
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.status,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                FutureBuilder<Product>(
                                    future: getProductById(item.productId),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Text(
                                          'Rp ${snapshot.data!.price}',
                                          style: TextStyle(fontSize: 15),
                                        );
                                      }
                                      return Container();
                                    })
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )));
    }
    return Container();
  }

  Future<Product> getProductById(String productId) async {
    TokenStorage tokenStorage = TokenStorage();
    String? token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    ApiService apiService = ApiService();
    Product product = await apiService.productsGetById(token!, productId);
    return product;
  }

  Future<List<dynamic>> _getCartItems(List<Cart> orders, int type) async {

    List<dynamic> items = [];

    for (var order in orders) {
      // Ambil semua produk secara paralel
      var products = await Future.wait(
          order.items.map((item) => getProductById(item.productId)));

      var itemOfType = order.items.where((item) {
        var product = products.firstWhere((p) => p.id == item.productId);
        return product.type == type;
      }).toList();

      if (itemOfType.isNotEmpty) {
        items.addAll(itemOfType);
      }
    }

    return items;
  }
  
  Future<List<Cart>> loadOrderData() async{
    TokenStorage tokenStorage = TokenStorage();
    String? token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    ApiService apiService = ApiService();
    List<Cart> cart = await apiService.cartGet(token!);
    return cart;
  }
}
