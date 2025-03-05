
class Packaging {

  final String id;
  final String name;
  final String description;
  final double price;
  final DateTime? lastUpdate;

  Packaging({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.lastUpdate,
  });

  factory Packaging.fromJson(Map<String, dynamic> json) {
    return Packaging(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      lastUpdate: json['last_update'] != null? DateTime.parse(json['last_update']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'last_update': lastUpdate?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}

