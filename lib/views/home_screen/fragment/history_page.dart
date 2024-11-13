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
    Product product = Product(      
        id: 2,
        name: "Obi Mangiring Merah-Ulos",
        tags: [Tag(tag: "terlaris"), Tag(tag: "promo spesial")],
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sit amet est eget orci pulvinar volutpat. Proin et elit sit amet felis condimentum convallis. Pellentesque id purus eros. Donec pharetra suscipit velit et convallis. Fusce finibus justo semper, mattis mauris ac, semper urna. Praesent nec turpis eros. Etiam mollis in nisi non accumsan. Aliquam id neque sit amet sem commodo eleifend ut vel tellus. Donec molestie lobortis mi ac pellentesque. Vestibulum posuere condimentum ornare.",
        price: 375000,
        stock: 123,
        favorite: 2,
        seen: 24,
        sold: 5,
        type: Product.CUSTOM,
        size: [
          "XL",
          "S",
          "M"
        ],
        imageUrl: [
          "https://down-id.img.susercontent.com/file/sg-11134201-22090-oj0c6ox3mxhv4e.webp",
          "https://down-id.img.susercontent.com/file/sg-11134201-22090-nzt8ypx3mxhv2d.webp",
          "https://down-id.img.susercontent.com/file/881145e16b11a838019faa3b79310e48.webp"
        ]);
Product product2 = Product(      
        id: 2,
        name: "Obi Mangiring Merah-Ulos",
        tags: [Tag(tag: "terlaris"), Tag(tag: "promo spesial")],
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sit amet est eget orci pulvinar volutpat. Proin et elit sit amet felis condimentum convallis. Pellentesque id purus eros. Donec pharetra suscipit velit et convallis. Fusce finibus justo semper, mattis mauris ac, semper urna. Praesent nec turpis eros. Etiam mollis in nisi non accumsan. Aliquam id neque sit amet sem commodo eleifend ut vel tellus. Donec molestie lobortis mi ac pellentesque. Vestibulum posuere condimentum ornare.",
        price: 375000,
        stock: 123,
        favorite: 2,
        seen: 24,
        sold: 5,
        type: Product.READY_TO_WEAR,
        size: [
          "XL",
          "S",
          "M"
        ],
        imageUrl: [
          "https://down-id.img.susercontent.com/file/sg-11134201-22090-oj0c6ox3mxhv4e.webp",
          "https://down-id.img.susercontent.com/file/sg-11134201-22090-nzt8ypx3mxhv2d.webp",
          "https://down-id.img.susercontent.com/file/881145e16b11a838019faa3b79310e48.webp"
        ]);


    // Contoh order dengan tanggal yang berbeda
    Order order1 = Order(
        id: 1,
        buyerId: 1,
        orderDate: DateTime(2024, 11, 7, 10, 0),
        totalPrice: 25000,
        items: [
          OrderItem(
              id: 1,
              orderId: 1,
              product: product,
              quantity: 1,
              status: Order.PROCESS,
              priceAtPurchase: product.price),
          OrderItem(
              id: 2,
              orderId: 2,
              product: product2,
              quantity: 1,
              status: Order.PROCESS,
              priceAtPurchase: product2.price),
          OrderItem(
              id: 3,
              orderId: 3,
              product: product2,
              quantity: 1,
              status: Order.COMPLETED,
              priceAtPurchase: product2.price)
        ]);
    Order order2 = Order(
        id: 2,
        buyerId: 1,
        orderDate: DateTime(2024, 11, 8, 12, 0),
        totalPrice: 15000,
        items: [
          OrderItem(
              id: 2,
              orderId: 2,
              product: product2,
              quantity: 1,
              status: Order.PROCESS,
              priceAtPurchase: product2.price)
        ]);

    // Daftar order diurutkan berdasarkan tanggal

    List<Order> dummy = [order1, order2];

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
              goToProductScreen(item.product);
            },
            child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                 
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8),bottomLeft: Radius.circular(8)),
                    child: AspectRatio(
                    aspectRatio: 4 / 5,
                    child: item.product.imageUrl.isNotEmpty
                        ? Image.network(
                            item.product.imageUrl.first,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            "assets/background/bg.png",
                            fit: BoxFit.cover,
                          ),
                  ),
                  )
                ),
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
                                  fontWeight: FontWeight.bold, fontSize: 20),
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
                                  fontSize: 15, fontWeight: FontWeight.bold),
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
          ))
          );
    }
    return Container();
  }

  List<dynamic> _getOrderItemsWithDate(List<Order> orders, int type) {
    orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

    List<dynamic> itemsWithDates = [];
    DateTime? lastDate;

    for (var order in orders) {
      var itemOfType =
          order.items.where((item) => item.product.type == type).toList();

      if (itemOfType.isNotEmpty) {
        if (lastDate == null || _isDifferentDate(lastDate, order.orderDate)) {
          itemsWithDates.add(_formatDate(order.orderDate));
        }

        itemsWithDates.addAll(itemOfType);
        lastDate = order.orderDate;
      }
    }

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
