
import 'package:jahit_baju/data/model/shipping.dart';

class ShippingResponse {
  bool error;
  String? message;
  Shipping? shipping;

  ShippingResponse({
    required this.error,
    this.message,   
    this.shipping
  });

  factory ShippingResponse.fromJson(Map<String, dynamic> json) {
    return ShippingResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",     
      shipping: json['data'] != null ? Shipping.fromJson(json['data']) : null     
    );
  }
}


class ShippingsResponse {
  bool error;
  String? message;
  List<Shipping>? shippings;

  ShippingsResponse({
    required this.error,
    this.message,
    this.shippings
  });

  factory ShippingsResponse.fromJson(Map<String, dynamic> json) {
    return ShippingsResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? null,
      shippings: json['data'] != null
          ? (json['data'] as List).map((item) => Shipping.fromJson(item)).toList()
          : null,    
    );
  }
}

