import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jahit_baju/model/order.dart';
import 'package:jahit_baju/model/order_item.dart';
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/views/product_screen/product_screen.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  var deviceWidth;
  @override
  Widget build(BuildContext context) {
    

    List<Order> dummy = [];

    List<Order> orders = dummy;

    deviceWidth = MediaQuery.of(context).size.width;
    var deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  SizedBox(height: 10),
                  _getOrderItemsWithDate(orders, Product.READY_TO_WEAR)
                          .isNotEmpty
                      ? Container(
                          child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _getOrderItemsWithDate(
                                  orders, Product.READY_TO_WEAR)
                              .length,
                          itemBuilder: (context, index) {
                            final item = _getOrderItemsWithDate(
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  SizedBox(height: 10),
                  _getOrderItemsWithDate(orders, Product.CUSTOM).isNotEmpty
                      ? Container(
                          child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              _getOrderItemsWithDate(orders, Product.CUSTOM)
                                  .length,
                          itemBuilder: (context, index) {
                            final item = _getOrderItemsWithDate(
                                orders, Product.CUSTOM)[index];

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
          margin: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8)
          ),
          child: InkWell(
            onTap: (){
              // goToProductScreen(item.productId);
            },
            child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container(
                 
                //   child: ClipRRect(
                //     borderRadius: BorderRadius.only(topLeft: Radius.circular(8),bottomLeft: Radius.circular(8)),
                //     child: AspectRatio(
                //     aspectRatio: 4 / 5,
                //     child: item.product.imageUrl.isNotEmpty
                //         ? Image.network(
                //             item.product.imageUrl.first,
                //             fit: BoxFit.cover,
                //           )
                //         : Image.asset(
                //             "assets/background/bg.png",
                //             fit: BoxFit.cover,
                //           ),
                //   ),
                //   )
                // ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text(
                        //       item.product.name,
                        //       style: TextStyle(
                        //           fontWeight: FontWeight.bold, fontSize: 20),
                        //     ),
                        //     Text(
                        //       item.product.description,
                        //       maxLines: 4,
                        //       overflow: TextOverflow.ellipsis,
                        //       softWrap: true,
                        //       style: TextStyle(fontSize: 15),
                        //     ),
                        //   ],
                        // ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text(
                        //       item.status,
                        //       style: TextStyle(
                        //           fontSize: 15, fontWeight: FontWeight.bold),
                        //     ),
                        //     Text(
                        //       'Rp ${item.product.price}',
                        //       style: TextStyle(fontSize: 15),
                        //     ),
                        //   ],
                        // )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ))
          );
    }
    return Container();
  }

  List<dynamic> _getOrderItemsWithDate(List<Order> orders, int type) {
    orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

    List<dynamic> itemsWithDates = [];
    DateTime? lastDate;

    // for (var order in orders) {
    //   var itemOfType =
    //       order.items.where((item) => item.product.type == type).toList();

    //   if (itemOfType.isNotEmpty) {
    //     if (lastDate == null || _isDifferentDate(lastDate, order.orderDate)) {
    //       itemsWithDates.add(_formatDate(order.orderDate));
    //     }

    //     itemsWithDates.addAll(itemOfType);
    //     lastDate = order.orderDate;
    //   }
    // }

    return itemsWithDates;
  }

  bool _isDifferentDate(DateTime date1, DateTime date2) {
    return date1.year != date2.year ||
        date1.month != date2.month ||
        date1.day != date2.day;
  }

  String _formatDate(DateTime date) {
    String formattedDate =
        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
    return formattedDate.toString();
  }
  
  void goToProductScreen(Product item) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductScreen(item)));
  }
}
