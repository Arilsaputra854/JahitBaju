import 'package:jahit_baju/model/order_item.dart';


class Order {
  final String id;
  final String buyerId;
  final DateTime orderDate;
  final int totalPrice;
  final String status;
  final List<OrderItem> items;
  final String createdAt;
  final String updatedAt;



  static const String PROCESS = "PROCESS";
  static const String COMPLETED = "COMPLETED";
  static const String CANCELED = "CANCELED";
  static const String PENDING = "PENDING";


  Order({
    required this.id,
    required this.buyerId,
    required this.orderDate,
    required this.totalPrice,
    this.status = PENDING,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      buyerId: json['buyerId'],
      orderDate: DateTime.parse(json['orderDate']),
      totalPrice: json['totalPrice'],
      status: json['status'] ?? 'pending',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      createdAt:json['createdAt'] ?? "",
      updatedAt:json['updatedAt'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'orderDate': orderDate.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
