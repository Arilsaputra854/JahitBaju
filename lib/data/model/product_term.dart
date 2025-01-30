class ProductTerm {
  String? id;
  String? color;
  String? size;
  String? texture;

  ProductTerm({this.id, this.color, this.size,this.texture});

  factory ProductTerm.fromJson(Map<String, dynamic> json) {
    return ProductTerm(
        id: json['id'],
        color: json['color'],
        size: json['size'],
        texture: json['texture']
    );
  }

}
