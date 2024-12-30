import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/viewmodels/cart_view_model.dart';
import 'package:jahit_baju/model/cart.dart';
import 'package:jahit_baju/model/order.dart';
import 'package:jahit_baju/model/order_item.dart';
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/views/product_screen/product_screen.dart';
import 'package:jahit_baju/views/shipping_screen/shipping_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var deviceWidth, deviceHeight;
  Cart? cart;

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
        create: (context) => CartViewModel(),
        child: Consumer<CartViewModel>(builder: (context, viewModel, child) {
          return Scaffold(
              appBar: AppBar(
                title: const Text("Cart"),
                centerTitle: true,
              ),
              bottomNavigationBar: Container(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0)),
                    backgroundColor: Colors.red, // Latar belakang merah
                    padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 30), // Padding agar tombol lebih besar
                  ),
                  onPressed: () => goToShippingScreen(cart),
                  child: const Text(
                    "Selanjutnya",
                    style: TextStyle(
                      color: Colors.white, // Warna teks putih
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              body: _body(viewModel));
        }));
  }

  //widget setiap item di cart
  Widget _buildCartItem(CartItem cartItem, Product item) {
    return Container(
        width: deviceWidth,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Colors.white),
        child: InkWell(
            onTap: () {},
            child: Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
                              child: item.type == Product.READY_TO_WEAR
                                  ? CachedNetworkImage(
                                      imageUrl: item.imageUrl.first,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) {
                                        return Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              color: Colors.grey,
                                            ));
                                      },
                                    )
                                  : SvgPicture.network(
                                      item.imageUrl.first,
                                      placeholderBuilder: (context) {
                                        return Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              color: Colors.grey,
                                            ));
                                      },
                                    )))),
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
                                item.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                convertToRupiah(item.price),
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                '${cartItem.size}',
                                style: const TextStyle(fontSize: 15),
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
                                    "${cartItem.quantity} pcs",
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                      onPressed: () => deleteCartItem(cartItem),
                                      icon: Icon(Icons.delete_rounded))
                                ],
                              ))
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )));
  }

  Widget itemCartShimmer() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 1, // Jumlah item shimmer
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 15,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 100,
                      height: 12,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  deleteCartItem(CartItem item) async {
    ApiService apiService = ApiService();

    var msg = await apiService.itemCartDelete(item);
    Fluttertoast.showToast(msg: msg);
    setState(() {});
  }

  goToShippingScreen(Cart? cart) {
    if (cart != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ShippingScreen(cart: cart,)));
    } else {
      Fluttertoast.showToast(
          msg: "Tidak ada produk, silakan belanja terlebih dahulu.");
    }
  }

  Widget _body(var viewModel) {
    return FutureBuilder(
        future: viewModel.getCart(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {}

          Cart? cart = snapshot.data as Cart?;
          this.cart = cart;

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: deviceWidth,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Siap Pakai",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<List<MapEntry<CartItem, Product>>?>(
                        future: viewModel.getCartItems(
                            cart?.items, Product.READY_TO_WEAR),
                        builder: (context, snapshot) {
                          print(snapshot.data);
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return itemCartShimmer();
                          } else if (snapshot.hasError) {
                            return itemCartShimmer();
                          } else if (snapshot.data != null) {
                            return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                var entry = snapshot.data![index];
                                CartItem cartItem = entry.key;
                                Product product = entry.value;

                                return _buildCartItem(cartItem, product);
                              },
                            );
                          } else {
                            return Container(
                              height: 100,
                              child: const Center(
                                child: Text("Tidak ada produk"),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Custom Produk",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<List<MapEntry<CartItem, Product>>?>(
                        future:
                            viewModel.getCartItems(cart?.items, Product.CUSTOM),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return itemCartShimmer();
                            
                          } if (snapshot.hasError) {
                            return itemCartShimmer();
                          } else if (snapshot.data != null) {
                              List<MapEntry<CartItem, Product>>? data =
                                  snapshot.data;

                              return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  var entry = snapshot.data![index];
                                  CartItem cartItem = entry.key;
                                  Product product = entry.value;

                                  return _buildCartItem(cartItem, product);
                                },
                              );
                            } else {
                              return Container(
                                height: 100,
                                child: const Center(
                                  child: Text("Tidak ada produk"),
                                ),
                              );
                            }
                        },
                      ),
                      const SizedBox(height: 30),
                      Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Custom",
                                style: TextStyle(fontSize: 15),
                              ),
                              Text(
                                "Rp 0.00",
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Text(
                                cart?.totalPrice != null
                                    ? convertToRupiah(cart!.totalPrice)
                                    : "Rp 0",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
