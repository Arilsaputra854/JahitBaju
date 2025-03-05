class ProductTerm {
  String? id;
  String? color;
  String? size;
  String? texture;
  final DateTime? lastUpdate;

  ProductTerm({this.id, this.color, this.size,this.texture,
    required this.lastUpdate,});

  factory ProductTerm.fromJson(Map<String, dynamic> json) {
    return ProductTerm(
        id: json['id'],
        color: json['color'],
        size: json['size'],
        texture: json['texture'],
      lastUpdate: json['last_update'] ? DateTime.parse(json['last_update']) : null,
    );
  }

}
