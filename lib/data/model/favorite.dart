class Favorite {
  int? id;
  final String? userId;
  final String productId;
  final DateTime? lastUpdate;

  Favorite({
    this.id,
    this.userId,
    required this.productId,
    required this.lastUpdate
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as int ?? 0,
      userId: json['user_id'] ?? "",
      productId: json['product_id'],
      lastUpdate: json['last_update'] != null ? DateTime.parse(json['last_update']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'last_update': lastUpdate?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}
