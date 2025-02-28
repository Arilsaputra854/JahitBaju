import 'package:jahit_baju/data/model/buy_feature.dart';

class BuyFeatureResponse {
  final bool error;
  final BuyFeature? data;
  final String? message;

  BuyFeatureResponse({
    required this.error,
    this.data,
    this.message,
  });

  factory BuyFeatureResponse.fromJson(Map<String, dynamic> json) {
    return BuyFeatureResponse(
      error: json['error'] ?? false,
      data: json['data'] != null ? BuyFeature.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

