import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/model/look.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/look_response.dart';
import 'package:jahit_baju/data/source/remote/response/order_response.dart';
import 'package:jahit_baju/helper/app_color.dart';
import 'package:jahit_baju/viewmodels/shipping_view_model.dart';
import 'package:jahit_baju/data/model/cart.dart';
import 'package:jahit_baju/data/model/order.dart';
import 'package:jahit_baju/data/model/packaging.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/model/shipping.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/views/address_screen/address_screen.dart';
import 'package:jahit_baju/views/payment_screen/payment_screen.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ShippingScreen extends StatefulWidget {
  final Cart? cart;
  final Product? product;
  final String? filename;
  final Look? look;
  final String? size;
  ShippingScreen(
      {this.cart,
      this.product,
      this.look,
      this.size,
      this.filename,
      super.key});

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  TextEditingController _descriptionController = TextEditingController();
  var deliveryChoosedIndex = -1;
  var packagingChoosedIndex = -1;

  Shipping? shipping;
  Packaging? packaging;

  int discount = 0;
  bool loading = false;

  var deviceWidth, deviceHeight;

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
        create: (context) => ShippingViewModel(ApiService(context)),
        child:
            Consumer<ShippingViewModel>(builder: (context, viewModel, child) {
          return Stack(children: [
            Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  title: const Text("Pengiriman",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  centerTitle: true,
                ),
                body: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _addressWidget(viewModel),
                        const SizedBox(height: 15),
                        _deliveryWidget(viewModel),
                        const SizedBox(height: 15),
                        _packagingWidget(viewModel),
                        const SizedBox(height: 15),
                        _descriptionWidget()
                      ],
                    ))),
                bottomNavigationBar: _bottomNavBar(viewModel)),
            if (loading) loadingWidget()
          ]);
        }));
  }

  _goToPaymentScreen(ShippingViewModel viewModel) async {
    setState(() {
      loading = true;
    });
    if ((deliveryChoosedIndex != -1 && shipping != "") &&
        (packagingChoosedIndex != -1 && packaging != "")) {
      if (widget.cart != null) {
        int customPrice = 0, rtwPrice = 0;
        for (var cart in widget.cart!.items) {
          if (cart.productId != null) {
            Product? product =
                await getProductById(cart.productId, ApiService(context));

            rtwPrice += product!.price.toInt();
          } else {
            Look? look = await getLook(cart.lookId!);

            customPrice += look!.price.toInt();
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
            description: _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : "-",
            totalPrice:
                (shipping!.price + widget.cart!.totalPrice + packaging!.price)
                    .toInt(),
            orderStatus: Order.WAITING_FOR_PAYMENT,
            paymentUrl: "");
        Logger log = Logger();
        log.d("Order Cart ${order.toJson()}");

        viewModel.createOrder(order).then((orderFromServer) {
          if (orderFromServer != null) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => PaymentScreen(order: orderFromServer)),
              (route) => route.settings.name == "Home",
            );

            setState(() {
              loading = false;
            });
          }
        });
      } else {
        int customPrice = 0, rtwPrice = 0;

        if (widget.look != null) {
          customPrice = widget.look!.price.toInt();
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
            description: _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : "-",
            product: widget.product,
            look: widget.look,
            totalPrice: (shipping!.price +
                    (widget.product?.price ?? 0) +
                    (widget.look?.price ?? 0) +
                    packaging!.price)
                .toInt(),
            orderStatus: Order.WAITING_FOR_PAYMENT,
            paymentUrl: "",
            shippingPrice: shipping!.price.toInt(),
            packagingPrice: packaging!.price.toInt(),
            discount: discount);

        await viewModel.buyNow(order, widget.filename).then((orderFromServer) {
          if (orderFromServer != null) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => PaymentScreen(order: orderFromServer)),
              (route) => route.settings.name == "Home",
            );
            setState(() {
              loading = false;
            });
          }
        });
      }
    } else {
      setState(() {
        loading = false;
      });
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
            Text(
              "Pakaian",
              style: TextStyle(fontSize: 14.sp),
            ),
            Text(
              widget.cart != null
                  ? convertToRupiah(widget.cart?.totalPrice)
                  : widget.look != null
                      ? convertToRupiah(widget.look?.price)
                      : convertToRupiah(widget.product?.price),
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Shipping",
              style: TextStyle(fontSize: 14.sp),
            ),
            Text(
              shipping != null ? convertToRupiah(shipping!.price) : "Rp 0.00",
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Packaging",
              style: TextStyle(fontSize: 14.sp),
            ),
            Text(
              packaging != null ? convertToRupiah(packaging!.price) : "Rp 0.00",
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            Text(
              shipping != null && packaging != null
                  ? widget.cart != null
                      ? convertToRupiah(shipping!.price +
                          widget.cart!.totalPrice +
                          packaging!.price)
                      : widget.product != null && widget.look != null
                          ? convertToRupiah(shipping!.price +
                              widget.product!.price +
                              widget.look!.price +
                              packaging!.price)
                          : widget.product != null
                              ? convertToRupiah(shipping!.price +
                                  widget.product!.price +
                                  packaging!.price)
                              : widget.look != null
                                  ? convertToRupiah(shipping!.price +
                                      widget.look!.price +
                                      packaging!.price)
                                  : convertToRupiah(0)
                  : convertToRupiah(0),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
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
                                fontWeight: FontWeight.bold, fontSize: 14.sp)),
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
        height: 80.h,
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
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp)),
                            Text(data[index].description,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12.sp)),
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
                  onPressed:
                      loading ? null : () => _goToPaymentScreen(viewModel),
                  child: Text(
                    "Bayar",
                    style: TextStyle(
                      fontSize: 14.sp,
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            const SizedBox(height: 5),
           FutureBuilder(
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

                      if (snapshot.data == null) {
                        goToAddress(snapshot.data);
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
                                  child: Text(
                                      snapshot.data ?? "Tidak ada alamat.",
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14.sp)))));
                    },
                  )
          ],
        ));
  }

  void showAddressRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Supaya tidak bisa ditutup dengan klik di luar dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alamat Diperlukan"),
          content: Text("Harap isi alamat Anda sebelum melanjutkan."),
          actions: [
            TextButton(
              onPressed: () {
                goToAddress("");
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  _packagingWidget(ShippingViewModel viewModel) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Packaging",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
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
                          child: Text(
                            "Tidak ada packaging.",
                            style: TextStyle(fontSize: 12.sp),
                          ),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            const SizedBox(height: 5),
            FutureBuilder<List<Shipping>?>(
                future: viewModel.getListShippingMethod(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return itemCartShimmer();
                  }
                  if(snapshot.data != null && snapshot.hasData){
                    return deliveryList(snapshot.data);
                  }else{
                    return Center(
                          child: Text(
                            "Tidak ada expedisi.",
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        );
                  }
                })
          ],
        ));
  }

  _descriptionWidget() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Catatan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            const SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Catatan untuk order. (opsional)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Future<Look?> getLook(String lookId) async {
    ApiService apiService = ApiService(context);
    LookResponse response = await apiService.getLookGetById(lookId);
    if (response.error) {
      Fluttertoast.showToast(msg: response.message!);
    } else {
      return response.look!;
    }
  }
}
