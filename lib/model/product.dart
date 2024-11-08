
class Product {

  static const READY_TO_WEAR = 1;
  static const CUSTOM = 2;

  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final int type;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.type,
    required this.imageUrl
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      stock: json['stock'],
      type: json['type'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'type': type,
      'image_url': imageUrl,
    };
  }
}
