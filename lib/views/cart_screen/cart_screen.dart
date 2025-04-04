import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jahit_baju/data/model/look.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/look_response.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/viewmodels/cart_view_model.dart';
import 'package:jahit_baju/data/model/cart.dart';
import 'package:jahit_baju/data/model/order.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/views/product_screen/rtw_product_screen.dart';
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
  late ApiService apiService;

  @override
  void initState() {
    apiService = ApiService(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
        create: (context) => CartViewModel(ApiService(context)),
        child: Consumer<CartViewModel>(builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.white,
              appBar: AppBar(
                title: const Text("Cart",style: TextStyle(                      
                      fontWeight: FontWeight.bold,
                    ),),
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
                  child: Text(
                    "Selanjutnya",
                    style: TextStyle(
                      color: Colors.white, // Warna teks putih
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp
                    ),
                  ),
                ),
              ),
              body: _body(viewModel));
        }));
  }

  //widget setiap item di cart
  Widget _buildCartItemRTW(CartItem cartItem, Product item) {
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
                              child: cartItem.productId != null
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
                                  : FutureBuilder(
                                      future: apiService.getCustomDesign(
                                          cartItem.customDesign!),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        return svgViewer(
                                            snapshot.data!['data']);
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
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14.sp),
                              ),
                              Text(
                                convertToRupiah(item.price),
                                style: TextStyle(fontSize: 12.sp),
                              ),
                              Text(
                                '${cartItem.size}',
                                style: TextStyle(fontSize: 12.sp),
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
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                      onPressed: () => deleteCartItem(cartItem),
                                      icon: Icon(Icons.delete_rounded,size: 16.w,))
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


  //widget setiap item di cart
  Widget _buildCartItemCustom(CartItem cartItem, Look item) {
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
                              child:  FutureBuilder(
                                      future: apiService.getCustomDesign(
                                          cartItem.customDesign!),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        return svgViewer(
                                            snapshot.data!['data']);
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
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14.sp),
                              ),
                              Text(
                                convertToRupiah(item.price),
                                style: TextStyle(fontSize: 12.sp),
                              ),
                              Text(
                                '${cartItem.size}',
                                style: TextStyle(fontSize: 12.sp),
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
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                      onPressed: () => deleteCartItem(cartItem),
                                      icon: Icon(Icons.delete_rounded,size: 16.w,))
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

  
  
  deleteCartItem(CartItem item) async {
    ApiService apiService = ApiService(context);

    var msg = await apiService.itemCartDelete(item);
    Fluttertoast.showToast(msg: msg);
    setState(() {});
  }

  goToShippingScreen(Cart? cart) {
    if (cart != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ShippingScreen(
                    cart: cart,
                  )));
    } else {
      Fluttertoast.showToast(
          msg: "Tidak ada produk, silakan belanja terlebih dahulu.");
    }
  }

  Widget _body(CartViewModel viewModel) {
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
                       Text(
                        "Siap Pakai",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.sp),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<List<MapEntry<CartItem, Product>>?>(
                        future: viewModel.getCartItems(
                            cart?.items),
                        builder: (context, snapshot) {
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

                                return _buildCartItemRTW(cartItem, product);
                              },
                            );
                          } else {
                            return Container(
                              height: 100,
                              child: Center(
                                child: Text("Tidak ada produk",style: TextStyle(fontSize: 12.sp),),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Kustom Produk",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.sp),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<List<MapEntry<CartItem, Look>>?>(
                        future:
                            viewModel.getLooksCartItems(cart?.items),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return itemCartShimmer();
                          }
                          if (snapshot.hasError) {
                            return itemCartShimmer();
                          } else if (snapshot.data != null) {
                            List<MapEntry<CartItem, Look>>? data =
                                snapshot.data;

                            return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                var entry = snapshot.data![index];
                                CartItem cartItem = entry.key;
                                Look product = entry.value;

                                return _buildCartItemCustom(cartItem, product);
                              },
                            );
                          } else {
                            return Container(
                              height: 100,
                              child:  Center(
                                child: Text("Tidak ada produk",style: TextStyle(fontSize: 12.sp),),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Siap pakai",
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              Text(
                                convertToRupiah(cart?.rtwPrice ?? 0),
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Text(
                                "Kostum",
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              Text(
                                convertToRupiah(cart?.customPrice ?? 0),
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Text(
                                "Total",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16.sp),
                              ),
                              Text(
                                cart?.totalPrice != null
                                    ? convertToRupiah(cart!.totalPrice)
                                    : "Rp 0",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16.sp),
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
