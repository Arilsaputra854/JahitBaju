import 'package:jahit_baju/data/model/product.dart';

class ProductResponse {
  bool error;
  String? message;
  Product? product;

  ProductResponse({
    required this.error,
    this.message,
    this.product
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? null,
      product: json['data'] != null? Product.fromJson(json['data'] ): null,
    );
  }
}

class ProductsResponse {
  bool error;
  String? message;
  List<Product>? products;

  ProductsResponse({
    required this.error,
    this.message,
    this.products
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? null,
      products: json['data'] != null
          ? (json['data'] as List).map((item) => Product.fromJson(item)).toList()
          : null,    
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'data': products?.map((product) => product.toJson()).toList(),
    };
  }
}


class ProductLatestResponse {
  bool error;
  String? message;
  DateTime? last_update;

  ProductLatestResponse({
    required this.error,
    this.message,
    this.last_update
  });

  factory ProductLatestResponse.fromJson(Map<String, dynamic> json) {
    return ProductLatestResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? null,
      last_update: json['data'] != null? DateTime.parse(json['data'] ): null,
    );
  }
}