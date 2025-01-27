import 'package:jahit_baju/data/model/product.dart';

class Order {
  final String? id;
  final String shippingId;
  final String packagingId;
  final String? cartId;
  final Product? product;
  final int totalPrice;
  final int rtwPrice;
  final int customPrice;
  final int packagingPrice;
  final int shippingPrice;
  final int discount;
  final int? quantity;
  final String? size;
  final DateTime orderCreated;
  final String orderStatus;
  final DateTime _lastUpdate; 
  final List<OrderItem> items;
  final String? paymentUrl;
  final DateTime expiredDate;
  final String resi;


  // // Status Order
  // static const String WAITING_FOR_PAYMENT = "Menunggu Pembayaran";
  // static const String DONE = "Pesanan Selesai";
  // static const String PROCESS = "Pesanan sedang disiapkan";
  // static const String ON_DELIVERY = "Dalam Pengiriman";
  // static const String CANCEL = "Pesanan Dibatalkan";

  static const String WAITING_FOR_PAYMENT = "WAITING FOR PAYMENT";
  static const String DONE = "DONE";
  static const String PROCESS = "PROCESS";
  static const String ARRIVED = "ARRIVED";
  static const String ON_DELIVERY = "ON_DELIVERY";
  static const String CANCEL = "CANCEL";

  // Constructor
  Order({
    this.id,
    required this.shippingId,
    required this.packagingId,
    this.cartId,
    this.product,
    this.size,
    this.quantity,
    required this.totalPrice,
    required this.rtwPrice,
    required this.customPrice,
    required this.shippingPrice,
    required this.packagingPrice,
    required this.discount,
    this.items = const [], // Default kosong jika tidak ada
    DateTime? orderCreated,
    required this.orderStatus,
    this.paymentUrl,
    DateTime? expiredDate,
    this.resi = "-"
  })  : orderCreated = orderCreated ?? DateTime.now(),
        _lastUpdate = DateTime.now(),expiredDate = expiredDate ?? DateTime.now().add(Duration(hours: 23,minutes: 50));
    

  DateTime get lastUpdate => _lastUpdate;

  // Factory method untuk membuat Order dari JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      shippingId: json['shipping_id'] ?? "",
      packagingId: json['packaging_id'] ?? "",
      cartId: json['cart_id'] ?? "",
      totalPrice: json['total_price'] ?? 0,
      customPrice: json['custom_price'] ?? 0,
      rtwPrice: json['rtw_price'] ?? 0,
      shippingPrice: json['shipping_price'] ?? 0,
      packagingPrice: json['packaging_price'] ?? 0,
      discount: json['discount'] ?? 0,
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
      resi: json['resi'] ?? "-",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'shipping_id': shippingId,
      'packaging_id': packagingId,
      'cart_id': cartId,
      'total_price': totalPrice,
      'rtw_price': rtwPrice,
      'custom_price': customPrice,
      'shipping_price': shippingPrice,
      'packaging_price': packagingPrice,
      'discount': discount,
      'order_created': orderCreated.toIso8601String(),
      'order_status': orderStatus,
      'last_update': _lastUpdate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'payment_url' : paymentUrl ?? "",
      'expired_date': expiredDate.toIso8601String(),
      'resi' : resi
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
  final String? customDesign;

  // Constructor
  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.size,
    required this.price,
    this.customDesign
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
      customDesign: json['custom_design']
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
      'custom_design' : customDesign
    };
  }
}