class Shipping {
  String id;
  String name;
  String imgUrl;
  int price;
  

  Shipping({
    this.id = "",
    required this.name,
    required this.imgUrl,
    required this.price
  });

factory Shipping.fromJson(Map<String, dynamic> json) {
    return Shipping(
      id: json['id'] ?? "", 
      name: json['name'] ?? "",  
      imgUrl: json['img_url'] ?? "",  
      price: json['price'] ?? "", 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'img_url': imgUrl,
      'price': price,
    };
  }
}
