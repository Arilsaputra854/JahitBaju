class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final int priceAtPurchase;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? customDesign;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    this.quantity = 1,
    required this.priceAtPurchase,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
    this.customDesign
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['orderId'],
      productId: json['productId'],
      quantity: json['quantity'] ?? 1,
      priceAtPurchase: json['priceAtPurchase'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      customDesign: json['custom_design']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'priceAtPurchase': priceAtPurchase,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'custom_design' : customDesign
    };
  }
}
