
class Packaging {

  final String id;
  final String name;
  final String description;
  final double price;

  Packaging({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory Packaging.fromJson(Map<String, dynamic> json) {
    return Packaging(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
    };
  }
}

