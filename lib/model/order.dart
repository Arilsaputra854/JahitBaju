import 'package:jahit_baju/model/order_item.dart';

class Order {
  final int id;
  final int buyerId;
  final DateTime orderDate;
   double totalPrice;
   List<OrderItem> items;


  static const String PROCESS = "PROCESS";
  static const String COMPLETED = "COMPLETED";
  static const String CANCELED = "CANCELED";

  Order({
    required this.id,
    required this.buyerId,
    required this.orderDate,
    required this.totalPrice,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<OrderItem> orderItems = itemsList.map((i) => OrderItem.fromJson(i)).toList();

    return Order(
      id: json['id'],
      buyerId: json['buyer_id'],
      orderDate: DateTime.parse(json['order_date']),
      totalPrice: json['total_price'].toDouble(),
      items: orderItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'order_date': orderDate.toIso8601String(),
      'total_price': totalPrice,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
