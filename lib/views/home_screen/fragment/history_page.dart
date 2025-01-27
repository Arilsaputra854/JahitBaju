import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/helper/app_color.dart';
import 'package:jahit_baju/data/model/order.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/source/remote/response/order_response.dart';
import 'package:jahit_baju/data/source/remote/response/product_response.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/views/payment_screen/payment_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../../detail_order_screen/detail_order_screen.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  var deviceWidth, deviceHeight;
  List<Order?> orders = [];

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          child: SingleChildScrollView(
              child: Container(
            width: deviceWidth,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Riwayat",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                SizedBox(height: 5),
                FutureBuilder(
                  future: getOrder(),
                  builder: (context, snapshot) {
                    //if fetch success
                    if (snapshot.hasData) {
                      orders = snapshot.data!;
                      Map<String, List<Order?>> groupedOrders =
                          sortOrderWithDate(orders);
                      //if data exists
                      if (orders.isNotEmpty) {
                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: groupedOrders.keys.length,
                          shrinkWrap: true,
                          itemBuilder: (context, dateIndex) {
                            String dateKey =
                                groupedOrders.keys.elementAt(dateIndex);
                            List<Order?> ordersByDate = groupedOrders[dateKey]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Text(
                                    DateFormat('EEEE, dd MMMM yyyy')
                                        .format(DateTime.parse(dateKey)),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16),
                                  ),
                                ),
                                ListView.builder(
                                  itemCount: ordersByDate.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, orderIndex) {
                                    Order? order = ordersByDate[orderIndex];
                                    return _buildCartItem(order!);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        //if data is empty
                        return Container(
                          height: deviceHeight * 0.5,
                          child: const Center(
                            child: Text("Tidak ada riwayat."),
                          ),
                        );
                      }
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      //if status is fetching data from server
                      return itemCartShimmer();
                    } else {
                      return Container(
                        height: deviceHeight * 0.5,
                        child: const Center(
                          child: Text("Tidak ada riwayat."),
                        ),
                      );
                    }
                  },
                )
              ],
            ),
          )),
          onRefresh: () async {
            setState(() {});
          },
        ));
  }

  Map<String, List<Order?>> sortOrderWithDate(List<Order?> orders) {
    Map<String, List<Order?>> sortedOrders = {};

    for (var order in orders) {
      if (order != null) {
        String dateKey = DateFormat('yyyy-MM-dd').format(order.orderCreated);

        if (!sortedOrders.containsKey(dateKey)) {
          sortedOrders[dateKey] = [];
        }
        sortedOrders[dateKey]!.add(order);
      }
    }

    Map<String, List<Order?>> sortedDescending = Map.fromEntries(
      sortedOrders.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );

    return sortedDescending;
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

  Widget _buildCartItem(Order order) {
    return Container(
        width: deviceWidth,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Colors.white),
        child: InkWell(
            onTap: () {
              // if (order.orderStatus == Order.WAITING_FOR_PAYMENT) {
              //   _goToPaymentScreen(order);
              // } else {
                _goToDetailOrderScreen(order);
              //}
            },
            child: Card(
                color: Colors.white,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Order Id: ${order.id}",
                              style: const TextStyle(
                                  fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                            order.orderStatus == Order.WAITING_FOR_PAYMENT
                                ? InkWell(
                                    onTap: () => _deleteOrder(order.id),
                                    child: Text(
                                      "Batal",
                                      style: const TextStyle(
                                          color: AppColor.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ))
                                : Container()
                          ],
                        ),
                    ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: order.items.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return FutureBuilder<Product?>(
                              future: getProduct(order.items[index].productId),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  Product product = snapshot.data!;
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          height: deviceWidth * 0.2,
                                          padding: const EdgeInsets.all(5),
                                          color: Colors.white,
                                          child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(8),
                                                      bottomLeft:
                                                          Radius.circular(8)),
                                              child: AspectRatio(
                                                  aspectRatio: 4 / 5,
                                                  child:
                                                      product.type ==
                                                              Product
                                                                  .READY_TO_WEAR
                                                          ? CachedNetworkImage(
                                                              imageUrl: product
                                                                  .imageUrl
                                                                  .first,
                                                              fit: BoxFit.cover,
                                                              placeholder:
                                                                  (context,
                                                                      url) {
                                                                return Shimmer
                                                                    .fromColors(
                                                                        baseColor:
                                                                            Colors.grey[
                                                                                300]!,
                                                                        highlightColor:
                                                                            Colors.grey[
                                                                                100]!,
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              double.infinity,
                                                                          height:
                                                                              double.infinity,
                                                                          color:
                                                                              Colors.grey,
                                                                        ));
                                                              },
                                                            )
                                                          : SvgPicture.network(
                                                              product.imageUrl
                                                                  .first,
                                                              placeholderBuilder:
                                                                  (context) {
                                                                return Shimmer
                                                                    .fromColors(
                                                                        baseColor:
                                                                            Colors.grey[
                                                                                300]!,
                                                                        highlightColor:
                                                                            Colors.grey[
                                                                                100]!,
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              double.infinity,
                                                                          height:
                                                                              double.infinity,
                                                                          color:
                                                                              Colors.grey,
                                                                        ));
                                                              },
                                                            )))),
                                      Expanded(
                                        child: Container(
                                          color: Colors.white,
                                          margin: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product.name,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                  Text(
                                                    '${order.items[index].size}',
                                                    style: const TextStyle(
                                                        fontSize: 15),
                                                  )
                                                ],
                                              ),
                                              Text(
                                                "${order.items[index].quantity} pcs",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                } else if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return itemCartShimmer();
                                } else {
                                  return Container();
                                }
                              });
                        }),                    
                    Text(
                      convertToRupiah(order.totalPrice),
                      style: const TextStyle(fontSize: 15),
                    ),
                    Text(
                      "${order.orderStatus}",
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    )
                  ],
                )))));
  }

  Future<List<Order?>> getOrder() async {
    ApiService apiService = ApiService(context);

    OrderResponse orders = await apiService.orderGet();

    if (orders.data is List<Order>) {
      return orders.data;
    } else {
      return [];
    }
  }

  Future<Product?> getProduct(String productId) async {
    ApiService apiService = ApiService(context);
    ProductResponse response = await apiService.productsGetById(productId);
    if (response.error) {
      Fluttertoast.showToast(msg: response.message!);
    } else {
      return response.product!;
    }
  }


  _deleteOrder(String? id) async {
    ApiService apiService = ApiService(context);
    OrderResponse response = await apiService.orderDelete(id);
    if (response.error) {
      Fluttertoast.showToast(msg: response.message!);
    } else {
      Fluttertoast.showToast(msg: response.message!);
      setState(() {});
    }
  }

  void _goToDetailOrderScreen(Order order) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => DetailOrderScreen(order)));
  }
}
