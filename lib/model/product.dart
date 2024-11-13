
class Product {

  static const READY_TO_WEAR = 1;
  static const CUSTOM = 2;

  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final int sold;
  final int seen;
  final int favorite;
  final int type;
  final List<String> imageUrl;
  final List<Tag> tags;
  final List<String> size;

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
    required this.size,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      stock: json['stock'],
      sold: json['sold'],
      seen: json['seen'],
      favorite: json['favorite'],
      type: json['type'],
      imageUrl: json['image_url'],
      tags: json['tags'],
      size: json['size'],
    );
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
      'image_url': imageUrl,
      'tags': tags,
      'size': size,
    };
  }
}

class Tag {
  final String tag;

  Tag({required this.tag});

factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      tag: json['tag'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
    };
  }
}