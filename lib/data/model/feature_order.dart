class FeatureOrder {
  final String? id;
  final String buyerId;
  final String featureId;
  final String paymentUrl;
  final DateTime expiryDate;
  final String paymentStatus;
  final String description;
  final int price;
  final DateTime? paymentDate;
  final DateTime? lastUpdate;
  final DateTime? orderCreated;
  final String? paymentMethod;

  FeatureOrder({
    this.id,
    required this.buyerId,
    required this.featureId,
    required this.paymentUrl,
    required this.expiryDate,
    required this.paymentStatus,
    required this.description,
    required this.price,
    this.paymentDate,
    this.lastUpdate,
    this.orderCreated,
    this.paymentMethod,
  });

  factory FeatureOrder.fromJson(Map<String, dynamic> json) {
    return FeatureOrder(
      id: json['id'],
      buyerId: json['buyer_id'],
      featureId: json['feature_id'],
      paymentUrl: json['payment_url'],
      expiryDate: DateTime.parse(json['expiry_date']),
      paymentStatus: json['payment_status'],
      description: json['description'],
      price: json['price'],
      paymentDate: json['payment_date'] != null ? DateTime.parse(json['payment_date']) : null,
      lastUpdate: json['last_update'] != null ? DateTime.parse(json['last_update']) : null,
      orderCreated: json['order_create'] != null ? DateTime.parse(json['order_create']) : null,
      paymentMethod: json['payment_method'],
    );
  }
}
