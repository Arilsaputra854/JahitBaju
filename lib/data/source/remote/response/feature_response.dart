import 'package:jahit_baju/data/model/feature_order.dart';

class BuyFeatureResponse {
  final bool error;
  final FeatureOrder? data;
  final String? message;

  BuyFeatureResponse({
    required this.error,
    this.data,
    this.message,
  });

  factory BuyFeatureResponse.fromJson(Map<String, dynamic> json) {
    return BuyFeatureResponse(
      error: json['error'] ?? false,
      data: json['data'] != null ? FeatureOrder.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

