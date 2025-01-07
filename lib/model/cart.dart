class Cart {
  final String id;
  final String buyerId;
  final double totalPrice;
  final List<CartItem> items;

  Cart({
    required this.id,
    required this.buyerId,
    required this.totalPrice,
    required this.items,
  });

  // Dari JSON ke objek Cart
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      buyerId: json['buyerId'],
      totalPrice: json['totalPrice'].toDouble(),
      items: (json['items'] as List)
          .map((itemJson) => CartItem.fromJson(itemJson))
          .toList(),
    );
  }

  // Objek Cart ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'totalPrice': totalPrice,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
  
}



class CartItem {
  final String id;
  final String cartId;
  final String productId;
  final String size;
  final int quantity;
  final double price;
  final String? customDesign;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.size,
    required this.quantity,
    required this.price,
    this.customDesign
  });

  // Dari JSON ke objek CartItem
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      cartId: json['cartId'],
      productId: json['productId'],
      size: json['size'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      customDesign: json['custom_design']
    );
  }

  // Objek CartItem ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cartId': cartId,
      'productId': productId,
      'size': size,
      'quantity': quantity,
      'price': price,
      'custom_design' : customDesign
    };
  }
}
