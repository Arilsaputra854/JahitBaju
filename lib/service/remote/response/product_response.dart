import 'package:jahit_baju/model/product.dart';

class ProductResponse {
  bool error;
  String? message;
  Product? product;

  ProductResponse({
    required this.error,
    this.message,
    this.product,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? null,
      product: json['data'] != null? Product.fromJson(json['data'] ): null,
    );
  }
}
