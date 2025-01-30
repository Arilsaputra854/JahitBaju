
import 'package:jahit_baju/data/model/product_term.dart';

class ProductTermResponse {
  bool error;
  String? message;
  ProductTerm? productTerm;

  ProductTermResponse({
    required this.error,    
    this.message,
    this.productTerm
  });

  factory ProductTermResponse.fromJson(Map<String, dynamic> json) {
    return ProductTermResponse(
      error: json['error'] ?? false,
      message: json['message'],  
      productTerm : json['data'] != null ? ProductTerm.fromJson(json['data']) : null
    );
  }
}

