import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jahit_baju/api/api_service.dart';
import 'package:jahit_baju/helper/app_color.dart';
import 'package:jahit_baju/model/cart.dart';
import 'package:jahit_baju/model/order.dart';
import 'package:jahit_baju/model/order_item.dart' as orderItem;
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/views/payment_screen/payment_screen.dart';
import 'package:jahit_baju/views/product_screen/product_screen.dart';
import 'package:shimmer/shimmer.dart';

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
        body: RefreshIndicator(
      child: Column(
        children: [
          Container(
            width: deviceWidth,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "History",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                SizedBox(height: 5),
                FutureBuilder(
                  future: getOrder(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      orders = snapshot.data!;
                      Map<String, List<Order?>> groupedOrders =
                          sortOrderWithDate(orders);

                      if (orders.isNotEmpty) {
                        return ListView.builder(
                          itemCount: groupedOrders.keys.length,
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
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
                        return Container(
                          height: 100,
                          child: const Center(
                            child: Text("Tidak ada history"),
                          ),
                        );
                      }
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return itemCartShimmer();
                    } else {
                      return itemCartShimmer();
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
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

    return sortedOrders;
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
              if (order.orderStatus == Order.WAITING_FOR_PAYMENT) {
                _goToPaymentScreen(order);
              }
            },
            child: Card(
                color: Colors.white,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "ID: ${order.id}",
                              style: const TextStyle(
                                  fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                            order.orderStatus == Order.WAITING_FOR_PAYMENT ? InkWell(                              
                                onTap: () => _deleteOrder(order.id),
                                child: Text(
                                  "Cancel",
                                  style: const TextStyle(
                                    color: AppColor.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                )) : Container()
                          ],
                        )),
                    ListView.builder(
                        itemCount: order.items.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return FutureBuilder<Product>(
                              future: getProduct(order.items[index].productId),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  Product product = snapshot.data!;
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          height: deviceWidth * 0.3,
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
                                                MainAxisAlignment.spaceBetween,
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
                                                    convertToRupiah(
                                                        product.price),
                                                    style: const TextStyle(
                                                        fontSize: 15),
                                                  ),
                                                  Text(
                                                    '${order.items[index].size}',
                                                    style: const TextStyle(
                                                        fontSize: 15),
                                                  )
                                                ],
                                              ),
                                              Container(
                                                  padding:
                                                      const EdgeInsets.all(3),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "${order.items[index].quantity} pcs",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        "${order.orderStatus}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    ],
                                                  ))
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                } else {
                                  return Container();
                                }
                              });
                        })
                  ],
                ))));
  }

  Future<List<Order?>> getOrder() async {
    ApiService apiService = ApiService();

    dynamic orders = await apiService.orderGet();
    if (orders is List<Order>) {
      return orders;
    } else {
      return [];
    }
  }

  Future<Product> getProduct(String productId) async {
    ApiService apiService = ApiService();
    Product product = await apiService.productsGetById(productId);
    return product;
  }

  void _goToPaymentScreen(order) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PaymentScreen(order: order)));
  }

}

  _deleteOrder(String? id) {}