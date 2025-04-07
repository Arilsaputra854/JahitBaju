import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/model/look.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/look_response.dart';
import 'package:jahit_baju/viewmodels/address_view_model.dart';
import 'package:jahit_baju/viewmodels/home_screen_view_model.dart';
import 'package:jahit_baju/viewmodels/shipping_view_model.dart';
import 'package:jahit_baju/data/model/cart.dart';
import 'package:jahit_baju/data/model/order.dart';
import 'package:jahit_baju/data/model/packaging.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/model/shipping.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/views/address_screen/address_screen.dart';
import 'package:jahit_baju/views/home_screen/fragment/home_page.dart';
import 'package:jahit_baju/views/home_screen/home_screen.dart';
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

  int discount = 0;

  var deviceWidth, deviceHeight;

  @override
  void initState() {
    Future.microtask(() {
      final viewModel = Provider.of<ShippingViewModel>(context, listen: false);
      viewModel.getListPackaging();
      viewModel.getUserAddress();
      if (viewModel.totalWeight == null) {
        if (widget.product != null) {
          viewModel.setTotalWeight(widget.product!.weight!);
        } else if (widget.cart != null) {
          int totalWeight = 0;
          for (CartItem item in widget.cart!.items) {
            totalWeight += item.weight;
          }
          viewModel.setTotalWeight(totalWeight);
        } else {
          viewModel.setTotalWeight(widget.look!.weight);
        }
      }
      viewModel.getListShippingMethod();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    return Consumer<ShippingViewModel>(builder: (context, viewModel, child) {
      return Stack(children: [
        Scaffold(
            backgroundColor: Colors.white,
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
        if (viewModel.loading) loadingWidget()
      ]);
    });
  }

  _goToPaymentScreen(ShippingViewModel viewModel) async {
    if ((deliveryChoosedIndex != -1 && viewModel.shipping != "") &&
        (packagingChoosedIndex != -1 && viewModel.packaging != "")) {
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
            packagingPrice: viewModel.packaging!.price.toInt(),
            shippingPrice: viewModel.shipping!.price!.toInt(),
            shippingId: viewModel.shipping!.id,
            packagingId: viewModel.packaging!.id,
            cartId: widget.cart!.id,
            description: _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : "-",
            totalPrice: (viewModel.shipping!.price! +
                    widget.cart!.totalPrice +
                    viewModel.packaging!.price)
                .toInt(),
            orderStatus: Order.WAITING_FOR_PAYMENT,
            paymentUrl: "");
        Logger log = Logger();
        log.d("Order Cart ${order.toJson()}");

        viewModel.createOrder(order).then((orderFromServer) {
          print("error ${viewModel.errorMsg}");
          if (viewModel.errorMsg != null) {
            Fluttertoast.showToast(msg: viewModel.errorMsg!);
          }
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

        if (widget.look != null) {
          customPrice = widget.look!.price.toInt();
        } else {
          rtwPrice = widget.product!.price.toInt();
        }

        //order direct buy now
        Order order = Order(
            customPrice: customPrice,
            rtwPrice: rtwPrice,
            shippingId: viewModel.shipping!.id,
            packagingId: viewModel.packaging!.id,
            size: widget.size,
            quantity: 1,
            description: _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : "-",
            product: widget.product,
            look: widget.look,
            totalPrice: (viewModel.shipping!.price! +
                    (widget.product?.price ?? 0) +
                    (widget.look?.price ?? 0) +
                    viewModel.packaging!.price)
                .toInt(),
            orderStatus: Order.WAITING_FOR_PAYMENT,
            paymentUrl: "",
            shippingPrice: viewModel.shipping!.price!.toInt(),
            packagingPrice: viewModel.packaging!.price.toInt(),
            discount: discount);

        await viewModel.buyNow(order, widget.filename).then((orderFromServer) {
          if (viewModel.errorMsg != null) {
            if (viewModel.errorMsg!.contains("product stock is not enogh")) {
              Fluttertoast.showToast(msg: "Stok produk telah habis");
              Provider.of<HomeScreenViewModel>(context, listen: false)
                  .refresh();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false,
              );
            }else{
              
              Fluttertoast.showToast(msg: viewModel.errorMsg!);
            }
          }
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

  Widget price(ShippingViewModel viewModel) {
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
              viewModel.shipping != null
                  ? convertToRupiah(viewModel.shipping!.price)
                  : "Rp 0.00",
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
              viewModel.packaging != null
                  ? convertToRupiah(viewModel.packaging!.price)
                  : "Rp 0.00",
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
              viewModel.shipping != null && viewModel.packaging != null
                  ? widget.cart != null
                      ? convertToRupiah(viewModel.shipping!.price! +
                          widget.cart!.totalPrice +
                          viewModel.packaging!.price)
                      : widget.product != null && widget.look != null
                          ? convertToRupiah(viewModel.shipping!.price! +
                              widget.product!.price +
                              widget.look!.price +
                              viewModel.packaging!.price)
                          : widget.product != null
                              ? convertToRupiah(viewModel.shipping!.price! +
                                  widget.product!.price +
                                  viewModel.packaging!.price)
                              : widget.look != null
                                  ? convertToRupiah(viewModel.shipping!.price! +
                                      widget.look!.price +
                                      viewModel.packaging!.price)
                                  : convertToRupiah(0)
                  : convertToRupiah(0),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
          ],
        ),
      ],
    ));
  }

  Widget deliveryList(ShippingViewModel viewModel) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: viewModel.listOfShipping.length,
        itemBuilder: (context, index) {
          if (viewModel.listOfShipping[index].price != null) {
            return InkWell(
                onTap: () {
                  setState(() {
                    deliveryChoosedIndex = index;
                  });

                  viewModel.setShipping(viewModel.listOfShipping[index]);
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
                        imageUrl: viewModel.listOfShipping[index].imgUrl,
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
                          Text(viewModel.listOfShipping[index].name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp)),
                          Text(convertToRupiah(
                              viewModel.listOfShipping[index].price))
                        ],
                      )
                    ],
                  ),
                )));
          } else {
            return Text(
              "Silakan atur alamat terlebihdahulu.",
              style: TextStyle(fontSize: 12.sp),
            );
          }
        });
  }

  Widget packaginglist(ShippingViewModel viewModel) {
    return Container(
        height: 80.h,
        child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.listOfPackaging.length,
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: () {
                    viewModel.setPackaging(viewModel.listOfPackaging[index]);
                    setState(() {
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
                            Text(viewModel.listOfPackaging[index].name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp)),
                            Text(viewModel.listOfPackaging[index].description,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12.sp)),
                            Text(convertToRupiah(
                                viewModel.listOfPackaging[index].price))
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
                price(viewModel),
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
                  onPressed: viewModel.loading
                      ? null
                      : () => _goToPaymentScreen(viewModel),
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

  void goToAddress(address, ShippingViewModel viewModel) {
    Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddressScreen(address)))
        .then((_) {
      viewModel.getListShippingMethod();
      viewModel.getUserAddress();
    });
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
            InkWell(
                onTap: () => goToAddress(viewModel.userAddress, viewModel),
                child: Card(
                    child: Container(
                        width: deviceWidth,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 2),
                            borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.all(10),
                        child: Text(
                            viewModel.userAddress?.streetAddress ??
                                "Tidak ada alamat.",
                            maxLines: 1,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14.sp)))))
          ],
        ));
  }

  void showAddressRequiredDialog(
      BuildContext context, ShippingViewModel viewModel) {
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
                goToAddress("", viewModel);
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
            Divider(),
            Text(
              "Packaging",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            const SizedBox(height: 5),
            viewModel.listOfPackaging.isNotEmpty
                ? packaginglist(viewModel)
                : Center(
                    child: Text(
                      "Tidak ada packaging.",
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  )
          ],
        ));
  }

  _deliveryWidget(ShippingViewModel viewModel) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(),
            Text(
              "Jasa Ekpedisi",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            const SizedBox(height: 5),
            viewModel.userAddress != null
                ? deliveryList(viewModel)
                : Center(
                    child: Text(
                      "Silakan atur alamat terlebihdahulu.",
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  )
          ],
        ));
  }

  _descriptionWidget() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(),
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
