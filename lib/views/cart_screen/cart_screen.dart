import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
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
    // // Contoh order dengan tanggal yang berbeda
    // Order order1 = Order(
    //     id: 1,
    //     buyerId: 1,
    //     orderDate: DateTime(2024, 11, 7, 10, 0),
    //     totalPrice: 25000,
    //     items: [
    //       OrderItem(
    //           id: 1,
    //           orderId: 1,
    //           product: SampleProduct.productRTW,
    //           quantity: 2,
    //           status: Order.PROCESS,
    //           priceAtPurchase: SampleProduct.productRTW.price),
    //     ]);
    // Order order2 = Order(
    //     id: 2,
    //     buyerId: 1,
    //     orderDate: DateTime(2024, 11, 8, 12, 0),
    //     totalPrice: 15000,
    //     items: [
    //       OrderItem(
    //           id: 2,
    //           orderId: 2,
    //           product: SampleProduct.productCustom,
    //           quantity: 1,
    //           status: Order.PROCESS,
    //           priceAtPurchase: SampleProduct.productRTW.price)
    //     ]);

    // // Daftar order diurutkan berdasarkan tanggal

    List<Order> dummy = [];

    List<Order> orders = dummy;

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
      body: SingleChildScrollView(
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  SizedBox(height: 10),
                  _getOrderItems(orders, Product.READY_TO_WEAR).isNotEmpty
                      ? Container(
                          child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              _getOrderItems(orders, Product.READY_TO_WEAR)
                                  .length,
                          itemBuilder: (context, index) {
                            final item = _getOrderItems(
                                orders, Product.READY_TO_WEAR)[index];

                            if (item is String) {
                              // Jika item adalah String, tampilkan sebagai tanggal
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
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
                        ),
                  SizedBox(height: 10),
                  Text(
                    "Custom Produk",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  SizedBox(height: 10),
                  _getOrderItems(orders, Product.CUSTOM).isNotEmpty
                      ? Container(
                          child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              _getOrderItems(orders, Product.CUSTOM).length,
                          itemBuilder: (context, index) {
                            final item =
                                _getOrderItems(orders, Product.CUSTOM)[index];

                            if (item is String) {
                              // Jika item adalah String, tampilkan sebagai tanggal
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
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
                        ),
                  SizedBox(height: 30),
                  Container(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Siap pakai",
                              style: TextStyle(
                                  fontSize: 15),
                            ),
                            Text(
                              "Rp 0.00",
                              style: TextStyle(
                                  fontSize: 15),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Custom",
                              style: TextStyle(
                                  fontSize: 15),
                            ),
                            Text(
                              "Rp 0.00",
                              style: TextStyle(
                                  fontSize: 15),
                            ),
                          ],
                        ),SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
      ),
    );
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
                          child: item.product.imageUrl.isNotEmpty
                              ? (item.product.type == Product.READY_TO_WEAR
                                  ? Image.network(
                                      item.product.imageUrl.first,
                                      fit: BoxFit.cover,
                                    )
                                  : SvgPicture.network(
                                      item.product.imageUrl.first))
                              : Placeholder()),
                    )),
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
                                Text(
                                  item.product.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                Text(
                                  item.product.description,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: TextStyle(fontSize: 15),
                                ),
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
                                Text(
                                  'Rp ${item.product.price}',
                                  style: TextStyle(fontSize: 15),
                                ),
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

  List<dynamic> _getOrderItems(List<Order> orders, int type) {
    orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

    List<dynamic> itemsWithDates = [];
    DateTime? lastDate;

    for (var order in orders) {
      var itemOfType =
          order.items.where((item) => item.product.type == type).toList();

      if (itemOfType.isNotEmpty) {
        itemsWithDates.addAll(itemOfType);
        lastDate = order.orderDate;
      }
    }

    return itemsWithDates;
  }
}
