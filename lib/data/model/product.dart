
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
  final int type;
  final List<String> imageUrl;
  final List<String> tags;
  final List<String>? category;
  final List<String> size;
  final List<String>? colors;
  final List<String>? features;  
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
    required this.type,
    required this.imageUrl,
    required this.tags,
    required this.category,
    required this.size,
    this.colors,
    this.features,
    required this.lastUpdate
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] ?? "",
      sold: json['sold'] ?? 0,
      seen: json['seen'] ?? 0,
      favorite: json['favorite'] ?? 0,
      type: json['type'] ?? 1,
      imageUrl: List<String>.from(json['images_url']?? []),
      tags: List<String>.from(json['tags'])?? [],           
      category: json['category'] != null ? List<String>.from(json['category']) : [],           
      size: List<String>.from(json['size'])?? [], 
      colors: json['colors'] != null ? List<String>.from(json['colors']) : [],
      features: json['features'] != null ? List<String>.from(json['features']): [],
      lastUpdate: json['last_update'] ?? DateTime.now().toString()
    );
  }

   static List<Product> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    jsonList.map((json) {
       return Product.fromJson(json);
    });
    
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
      'type': type,
      'images_url': imageUrl,
      'tags': tags,
      'category': category,
      'size': size,
      'colors': colors,
      'features': features,
      'last_update' : lastUpdate
    };
  }
}
