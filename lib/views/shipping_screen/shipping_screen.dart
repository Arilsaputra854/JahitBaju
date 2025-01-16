import 'package:cached_network_image/cached_network_image.dart';
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

  int discount = 0;

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
                title: const Text("Pengiriman",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _addressWidget(viewModel),
                  const SizedBox(height: 15),
                  _deliveryWidget(viewModel),
                  const SizedBox(height: 15),
                  _packagingWidget(viewModel)
                ],
              )),
              bottomNavigationBar: _bottomNavBar(viewModel));
        }));
  }

  _goToPaymentScreen(ShippingViewModel viewModel) async {
    if ((deliveryChoosedIndex != -1 && shipping != "") &&
        (packagingChoosedIndex != -1 && packaging != "")) {
      if (widget.cart != null) {
        int customPrice = 0, rtwPrice = 0;
        for (var cart in widget.cart!.items) {
          Product? product = await getProductById(cart.productId);

          if (product!.type == Product.CUSTOM) {
            customPrice += product.price.toInt();
          } else {
            rtwPrice += product.price.toInt();
          }
        }

        //order from cart
        Order order = Order(
            customPrice: customPrice,
            rtwPrice: rtwPrice,
            discount: discount,
            packagingPrice: packaging!.price.toInt(),
            shippingPrice: shipping!.price.toInt(),
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
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => PaymentScreen(order: orderFromServer)),
              (route) => route.settings.name == "Home",
            );
          }
        });
      } else {
        int customPrice = 0, rtwPrice = 0;        

        if (widget.product!.type == Product.CUSTOM) {
          customPrice = widget.product!.price.toInt();
        } else {
          rtwPrice = widget.product!.price.toInt();
        }

        //order direct buy now
        Order order = Order(
            customPrice: customPrice,
            rtwPrice: rtwPrice,
            shippingId: shipping!.id,
            packagingId: packaging!.id,
            size: widget.size,
            quantity: 1,
            product: widget.product,
            totalPrice:
                (shipping!.price + widget.product!.price + packaging!.price)
                    .toInt(),
            orderStatus: Order.WAITING_FOR_PAYMENT,
            paymentUrl: "",
            shippingPrice: shipping!.price.toInt(),
            packagingPrice: packaging!.price.toInt(),
            discount: discount);
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

  Widget deliveryList(var data) {
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
                    CachedNetworkImage(
                      imageUrl: data[index].imgUrl,
                      errorWidget: (context, url, error) {
                        return Icon(Icons.warning);
                      },
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
        padding: const EdgeInsets.all(20),
        child: Wrap(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
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
            )
          ],
        ));
  }

  void goToAddress(address) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddressScreen(address)));
  }

  _addressWidget(ShippingViewModel viewModel) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Alamat",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 5),
            FutureBuilder(
                future: viewModel.getListShippingMethod(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  List<Shipping> data = snapshot.data;

                  return FutureBuilder(
                    future: viewModel.getUserAddress(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Shimmer(
                          child: SizedBox(
                            height: 20,
                          ),
                          gradient: LinearGradient(
                              colors: [Colors.white, Colors.grey]),
                        );
                      }
                      return InkWell(
                          onTap: () => goToAddress(snapshot.data),
                          child: Card(
                              child: Container(
                                  width: deviceWidth,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(width: 2),
                                      borderRadius: BorderRadius.circular(12)),
                                  padding: EdgeInsets.all(10),
                                  child: Text(snapshot.data,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16)))));
                    },
                  );
                })
          ],
        ));
  }

  _packagingWidget(ShippingViewModel viewModel) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Packaging",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 5),
            FutureBuilder(
                future: viewModel.getListPackaging(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  List<Packaging> data = snapshot.data;

                  return data.isNotEmpty
                      ? packaginglist(data)
                      : Center(
                          child: Text("Tidak ada packaging."),
                        );
                })
          ],
        ));
  }

  _deliveryWidget(ShippingViewModel viewModel) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Jasa Ekpedisi",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 5),
            FutureBuilder(
                future: viewModel.getListShippingMethod(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  List<Shipping> data = snapshot.data;

                  return data.isNotEmpty
                      ? deliveryList(data)
                      : Center(
                          child: Text("Tidak ada expedisi."),
                        );
                })
          ],
        ));
  }
}
