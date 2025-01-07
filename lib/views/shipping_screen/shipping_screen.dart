import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/service/remote/response/order_response.dart';
import 'package:jahit_baju/viewmodels/shipping_view_model.dart';
import 'package:jahit_baju/model/cart.dart';
import 'package:jahit_baju/model/order.dart';
import 'package:jahit_baju/model/packaging.dart';
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/model/shipping.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/views/address_screen/address_screen.dart';
import 'package:jahit_baju/views/payment_screen/payment_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ShippingScreen extends StatefulWidget {
  final Cart? cart;
  final Product? product;
  final String? size;
  ShippingScreen({this.cart, this.product, this.size, super.key});

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  var deliveryChoosedIndex = -1;
  var packagingChoosedIndex = -1;

  Shipping? shipping;
  Packaging? packaging;

  var deviceWidth, deviceHeight;

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
        create: (context) => ShippingViewModel(),
        child:
            Consumer<ShippingViewModel>(builder: (context, viewModel, child) {
          return Scaffold(
              appBar: AppBar(
                elevation: 0,
                title: const Text("Delivery",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder(
                      future: viewModel.getListShippingMethod(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        List<Shipping> data = snapshot.data;

                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Address",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 5),
                              FutureBuilder(
                                  future: viewModel.getUserAddress(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Shimmer(
                                        child: SizedBox(
                                          height: 20,
                                        ),
                                        gradient: LinearGradient(colors: [
                                          Colors.white,
                                          Colors.grey
                                        ]),
                                      );
                                    }
                                    return InkWell(
                                        onTap: () => goToAddress(snapshot.data),
                                        child: Card(
                                            child: Container(
                                                width: deviceWidth,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border:
                                                        Border.all(width: 2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                padding: EdgeInsets.all(10),
                                                child: Text(snapshot.data,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 16)))));
                                  }),
                            ],
                          ),
                        );
                      }),
                  FutureBuilder(
                      future: viewModel.getListShippingMethod(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        List<Shipping> data = snapshot.data;

                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Reguler",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 5),
                              data.isNotEmpty
                                  ? shippingList(data)
                                  : Center(
                                      child: Text("Tidak ada expedisi."),
                                    )
                            ],
                          ),
                        );
                      }),
                  const SizedBox(height: 15),
                  FutureBuilder(
                      future: viewModel.getListPackaging(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        List<Packaging> data = snapshot.data;

                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Packaging",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 5),
                              data.isNotEmpty
                                  ? packaginglist(data)
                                  : Center(
                                      child: Text("Tidak ada packaging."),
                                    )
                            ],
                          ),
                        );
                      })
                ],
              )),
              bottomNavigationBar: _bottomNavBar(viewModel));
        }));
  }

  _goToPaymentScreen(ShippingViewModel viewModel) async {
    if ((deliveryChoosedIndex != -1 && shipping != "") &&
        (packagingChoosedIndex != -1 && packaging != "")) {
      if (widget.cart != null) {
        //order from cart
        Order order = Order(
            shippingId: shipping!.id,
            packagingId: packaging!.id,
            cartId: widget.cart!.id,
            totalPrice:
                (shipping!.price + widget.cart!.totalPrice + packaging!.price)
                    .toInt(),
            orderStatus: Order.WAITING_FOR_PAYMENT,
            paymentUrl: "");
        viewModel.createOrder(order).then((orderFromServer) {
          if (orderFromServer != null) {
            print("Data order yang diterima dari server :\n${order.toJson()}");
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => PaymentScreen(order: orderFromServer)),
              (route) => route.settings.name == "Home",
            );
          }
        });
      } else {
        //order direct buy now
        Order order = Order(
            shippingId: shipping!.id,
            packagingId: packaging!.id,
            size: widget.size,
            quantity: 1,
            product:widget.product,
            totalPrice:
                (shipping!.price + widget.product!.price + packaging!.price)
                    .toInt(),
            orderStatus: Order.WAITING_FOR_PAYMENT,
            paymentUrl: "");
        await viewModel.buyNow(order).then((orderFromServer) {
          if (orderFromServer != null) {            
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => PaymentScreen(order: orderFromServer)),
              (route) => route.settings.name == "Home",
            );
          }
        });
      }
    } else {
      Fluttertoast.showToast(
          msg: "Silakan pilih jasa pengiriman dan tipe packaging.");
    }
  }

  Widget price() {
    return Container(
        child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Pakaian",
              style: TextStyle(fontSize: 15),
            ),
            Text(
              widget.cart != null
                  ? convertToRupiah(widget.cart?.totalPrice)
                  : widget.product != null
                      ? convertToRupiah(widget.product?.price)
                      : "Rp 0.00",
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Shipping",
              style: TextStyle(fontSize: 15),
            ),
            Text(
              shipping != null ? convertToRupiah(shipping!.price) : "Rp 0.00",
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Packaging",
              style: TextStyle(fontSize: 15),
            ),
            Text(
              packaging != null ? convertToRupiah(packaging!.price) : "Rp 0.00",
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Total",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              shipping != null && packaging != null
                  ? widget.cart != null
                      ? convertToRupiah(shipping!.price +
                          widget.cart!.totalPrice +
                          packaging!.price)
                      : widget.product != null
                          ? convertToRupiah(shipping!.price +
                              widget.product!.price +
                              packaging!.price)
                          : "Rp 0.00"
                  : "Rp 0.00",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ],
    ));
  }

  Widget shippingList(var data) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return InkWell(
              onTap: () {
                setState(() {
                  deliveryChoosedIndex = index;
                  shipping = data[index];
                });
              },
              child: Card(
                  child: Container(
                decoration: deliveryChoosedIndex == index
                    ? BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 2),
                        borderRadius: BorderRadius.circular(12))
                    : BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 0),
                        borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Image.network(
                      data[index].imgUrl,
                      width: 50,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data[index].name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(convertToRupiah(data[index].price))
                      ],
                    )
                  ],
                ),
              )));
        });
  }

  Widget packaginglist(var data) {
    return Container(
        height: 100,
        child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: () {
                    setState(() {
                      packaging = data[index];
                      packagingChoosedIndex = index;
                    });
                  },
                  child: Card(
                      child: Container(
                    decoration: packagingChoosedIndex == index
                        ? BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 2),
                            borderRadius: BorderRadius.circular(12))
                        : BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 0),
                            borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data[index].name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(data[index].description,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12)),
                            Text(convertToRupiah(data[index].price))
                          ],
                        )
                      ],
                    ),
                  )));
            }));
  }

  Widget _bottomNavBar(ShippingViewModel viewModel) {
    return Container(
        height: deviceHeight * 0.38,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            price(),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0)),
                backgroundColor: Colors.red, // Latar belakang merah
                padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 30), // Padding agar tombol lebih besar
              ),
              onPressed: () => _goToPaymentScreen(viewModel),
              child: const Text(
                "Bayar",
                style: TextStyle(
                  color: Colors.white, // Warna teks putih
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ));
  }

  void goToAddress(address) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddressScreen(address)));
  }
}
