import 'dart:convert';

class Product {
  static const READY_TO_WEAR = 1;
  static const CUSTOM = 2;

  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final int sold;
  final int seen;
  final int favorite;
  final List<String> imageUrl;
  final List<String> tags;
  final List<String>? category;
  final List<String> size;
  final List<String>? colors;
  final List<String>? materials;
  final String? productCode;
  final int? weight;
  final String lastUpdate;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.sold,
    required this.seen,
    required this.favorite,
    required this.imageUrl,
    required this.tags,
    required this.category,
    required this.size,
    this.colors,
    this.materials,
    this.productCode,
    this.weight,
    required this.lastUpdate,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] ?? 0,
      sold: json['sold'] ?? 0,
      seen: json['seen'] ?? 0,
      favorite: json['favorite'] ?? 0,
      imageUrl: List<String>.from(json['images_url'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'] != null ? List<String>.from(json['category']) : [],
      size: List<String>.from(json['size'] ?? []),
      colors: json['colors'] != null ? List<String>.from(json['colors']) : [],
      materials: json['materials'] != null ? List<String>.from(json['materials']) : [],
      productCode: json['product_code'],
      weight: json['weight'] ?? 0,
      lastUpdate: json['last_update'] ?? DateTime.now().toIso8601String(),
    );
  }

  static List<Product> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Product.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'sold': sold,
      'seen': seen,
      'favorite': favorite,
      'images_url': imageUrl,
      'tags': tags,
      'category': category,
      'size': size,
      'colors': colors,
      'materials': materials,
      'product_code': productCode,
      'weight': weight,
      'last_update': lastUpdate,
    };
  }
}
