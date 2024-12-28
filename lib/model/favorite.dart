class Favorite {
  int? id;
  final String? userId;
  final String productId;

  Favorite({
    this.id,
    this.userId,
    required this.productId
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as int ?? 0,
      userId: json['user_id'] ?? "",
      productId: json['product_id']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId
    };
  }
}
