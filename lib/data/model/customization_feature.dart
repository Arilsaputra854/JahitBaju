class CustomizationAccess {
  final String id;
  final String name;
  final String? description;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomizationAccess({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomizationAccess.fromJson(Map<String, dynamic> json) {
    return CustomizationAccess(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
