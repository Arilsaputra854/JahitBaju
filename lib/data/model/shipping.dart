class Shipping {
  String id;
  String name;
  String imgUrl;
  int? price;
  final DateTime? lastUpdate;
  

  Shipping({
    required this.id,
    required this.name,
    required this.imgUrl,
    this.price,
    required this.lastUpdate,
  });

factory Shipping.fromJson(Map<String, dynamic> json) {
    return Shipping(
      id: json['id'], 
      name: json['name'],  
      imgUrl: json['img_url'],  
      price: json['price'] ?? null, 
      lastUpdate: json['last_update'] != null ? DateTime.parse(json['last_update']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'img_url': imgUrl,
      'price': price,
      'last_update': lastUpdate?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}
