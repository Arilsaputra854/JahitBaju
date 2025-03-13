class Cart {
  final String id;
  final String buyerId;
  final double totalPrice;
  final double rtwPrice;
  final double customPrice;
  final List<CartItem> items;
  final DateTime? lastUpdate;

  Cart({
    required this.id,
    required this.buyerId,
    required this.totalPrice,
    required this.rtwPrice,
    required this.customPrice,
    required this.items,
    this.lastUpdate,
  });

  // Dari JSON ke objek Cart
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      buyerId: json['buyer_id'],
      totalPrice: json['total_price'].toDouble(),
      rtwPrice: json['rtw_price'].toDouble(),
      customPrice: json['custom_price'].toDouble(),
      items: (json['items'] as List)
          .map((itemJson) => CartItem.fromJson(itemJson))
          .toList(),
      lastUpdate: json['last_update'] != null?  DateTime.parse(json['last_update']) : null,
    );
  }

  // Objek Cart ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'total_price': totalPrice,
      'custom_price' : customPrice,
      'rtw_price' : rtwPrice,
      'items': items.map((item) => item.toJson()).toList(),
      'last_update': lastUpdate?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
  
}



class CartItem {
  final String id;
  final String cartId;
  final String? productId;
  final String? lookId;
  final String size;
  final int quantity;
  final int weight;
  final double price;
  final String? customDesign;
  final DateTime? lastUpdate;


  CartItem({
    required this.id,
    required this.cartId,
    this.productId,
    this.lookId,
    required this.size,
    required this.quantity,
    required this.weight,
    required this.price,
    this.customDesign,
    this.lastUpdate,
  });

  // Dari JSON ke objek CartItem
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      cartId: json['cart_id'],
      productId: json['product_id'],
      lookId: json['look_id'],
      size: json['size'],
      quantity: json['quantity'],
      weight: json['weight'],
      price: json['price'].toDouble(),
      customDesign: json['custom_design'],
      lastUpdate: json['last_update'] != null?  DateTime.parse(json['last_update']) : null,
    );
  }

  // Objek CartItem ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cartId': cartId,
      'productId': productId,
      'look_id': lookId,
      'size': size,
      'quantity': quantity,
      'weight': weight,
      'price': price,
      'custom_design' : customDesign,
      'last_update': lastUpdate?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}
