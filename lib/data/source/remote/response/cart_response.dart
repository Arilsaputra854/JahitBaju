
import 'package:jahit_baju/data/model/cart.dart';

class CartResponse {
  bool error;
  String? message;
  Cart? cart;

  CartResponse({
    required this.error,
    this.message,   
    this.cart
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",     
      cart: json['data']  != null? Cart.fromJson(json['data']) : null
    );
  }
}
