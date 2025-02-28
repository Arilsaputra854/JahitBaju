

import 'package:jahit_baju/data/model/customization_feature.dart';

class CustomizationAccessResponse {
  final bool error;
  final String? message;
  final CustomizationAccess? customizationAccess;

  CustomizationAccessResponse({
    required this.error,
    this.message,
    this.customizationAccess,
  });

  factory CustomizationAccessResponse.fromJson(Map<String, dynamic> json) {
    return CustomizationAccessResponse(
      error: json['error'] ?? false,
      message: json['message'],
      customizationAccess: json['data'] != null
          ? CustomizationAccess.fromJson(json['data'])
          : null,
    );
  }
}
