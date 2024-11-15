import 'package:jahit_baju/model/product.dart';

class OrderItem {
  final int id;
  final int orderId;
  final Product product;
  final int quantity;
  final String status;
  final double priceAtPurchase;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.product,
    required this.quantity,
    required this.status,
    required this.priceAtPurchase,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      product: json['product'],
      status: json['status'],
      quantity: json['quantity'],
      priceAtPurchase: json['price_at_purchase'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product': product.toJson(),
      'status': status,
      'quantity': quantity,
      'price_at_purchase': priceAtPurchase,
    };
  }
}
