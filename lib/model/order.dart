class Order {
  final String? id;
  final String buyerId;
  final String shippingId;
  final String packagingId;
  final String cartId;
  final int totalPrice;
  final DateTime orderCreated;
  final String orderStatus;
  final DateTime _lastUpdate; // Properti privat untuk last_update
  final List<OrderItem> items; // Properti biasa untuk daftar item
  final String? paymentUrl;
  final DateTime expiredDate;


  // Status Order
  static const String WAITING_FOR_PAYMENT = "WAITING FOR PAYMENT";
  static const String DONE = "DONE";
  static const String PROCESS = "PROCESS";
  static const String ON_DELIVERY = "ON DELIVERY";
  static const String CANCEL = "CANCELED";


  // Constructor
  Order({
    this.id,
    required this.buyerId,
    required this.shippingId,
    required this.packagingId,
    required this.cartId,
    required this.totalPrice,
    this.items = const [], // Default kosong jika tidak ada
    DateTime? orderCreated,
    required this.orderStatus,
    this.paymentUrl,
    DateTime? expiredDate
  })  : orderCreated = orderCreated ?? DateTime.now(),
        _lastUpdate = DateTime.now(),expiredDate = expiredDate ?? DateTime.now().add(Duration(hours: 23,minutes: 50));
    

  DateTime get lastUpdate => _lastUpdate;

  // Factory method untuk membuat Order dari JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      buyerId: json['buyer_id'] ?? "",
      shippingId: json['shipping_id'] ?? "",
      packagingId: json['packaging_id'] ?? "",
      cartId: json['cart_id'] ?? "",
      totalPrice: json['total_price'] ?? 0,
      orderCreated: json['order_created'] != null
          ? DateTime.parse(json['order_created'])
          : null,
      orderStatus: json['order_status'] ?? "",
      items: (json['items'] as List<dynamic>)
          .map((itemJson) => OrderItem.fromJson(itemJson))
          .toList(), // Parsing daftar items
      paymentUrl: json['payment_url'] ?? "",
      expiredDate: json['expired_date'] != null
          ? DateTime.parse(json['expired_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'buyer_id': buyerId,
      'shipping_id': shippingId,
      'packaging_id': packagingId,
      'cart_id': cartId,
      'total_price': totalPrice,
      'order_created': orderCreated.toIso8601String(),
      'order_status': orderStatus,
      'last_update': _lastUpdate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'payment_url' : paymentUrl ?? "",
      'expired_date': expiredDate.toIso8601String(),
    };
  }

  // Factory untuk membuat daftar Order dari JSON list
  static List<Order> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Order.fromJson(json)).toList();
  }
}


class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final String size;
  final int price;

  // Constructor
  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.size,
    required this.price,
  });

  // Factory method untuk membuat OrderItem dari JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?? "",
      orderId: json['orderId']?? "",
      productId: json['productId']?? "",
      quantity: json['quantity']?? "",
      size: json['size']?? "",
      price: json['price']?? "",
    );
  }

  // Method untuk mengonversi OrderItem menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'size': size,
      'price': price,
    };
  }
}