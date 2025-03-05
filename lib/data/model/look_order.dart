class LookOrder {
  final String id;
  final String buyerId;
  final String lookId;
  final int price;
  final DateTime orderCreated;
  final String paymentStatus;
  final DateTime lastUpdate;
  final String? paymentUrl;
  final DateTime? paymentDate;
  final String? paymentMethod;
  final String description;
  final DateTime expiredDate;

  static const String PENDING = "PENDING";
  static const String PAID = "PAID";

  LookOrder({
    required this.id,
    required this.buyerId,
    required this.lookId,
    required this.price,
    required this.orderCreated,
    required this.paymentStatus,
    required this.lastUpdate,
    this.paymentUrl,
    required this.expiredDate,
    this.paymentDate,
    this.paymentMethod,
    required this.description,
  });

  /// Konversi dari JSON ke LookOrder
  factory LookOrder.fromJson(Map<String, dynamic> json) {
    return LookOrder(
      id: json['id'],
      buyerId: json['buyer_id'],
      lookId: json['look_id'],
      price: json['price'],
      orderCreated: DateTime.parse(json['order_created']),
      paymentStatus: json['payment_status'],
      lastUpdate: DateTime.parse(json['last_update']),
      paymentUrl: json['payment_url'],
      expiredDate: DateTime.parse(json['expiry_date']),
      description: json['description'],
      paymentDate: json['payment_date'] != null ? DateTime.parse(json['payment_date']) : null,
      paymentMethod: json['payment_method'],
    );
  }

  /// Konversi dari LookOrder ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'look_id': lookId,
      'price': price,
      'order_created': orderCreated.toIso8601String(),
      'payment_status': paymentStatus,
      'last_update': lastUpdate.toIso8601String(),
      'payment_url': paymentUrl,
      'expiry_date': expiredDate.toIso8601String(),
      'description': description,
      'payment_date': paymentDate?.toIso8601String(),
      'payment_method': paymentMethod,
    };
  }
}
