
import 'package:jahit_baju/data/model/feature_order.dart';

class OrderFeatureResponse {
  bool error;
  String? message;
  FeatureOrder? data;

  OrderFeatureResponse({
    required this.error,
    this.message,   
    this.data
  });

  factory OrderFeatureResponse.fromJson(Map<String, dynamic> json) {
    return OrderFeatureResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",     
      data: json['data'] !=null ? FeatureOrder.fromJson(json['data']) : null
    );
  }
}
