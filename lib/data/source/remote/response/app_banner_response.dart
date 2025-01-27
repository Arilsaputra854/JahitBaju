
import 'package:jahit_baju/data/model/app_banner.dart';

class AppBannerResponse {
  bool error;
  String? message;
  List<AppBanner>? appBanner;

  AppBannerResponse({
    required this.error,
    this.appBanner,    
    this.message,
  });

  factory AppBannerResponse.fromJson(Map<String, dynamic> json) {
    return AppBannerResponse(
      error: json['error'] ?? false,
      message: json['message'] != null ? json['data']['message'] : null,  
      appBanner: json['data'] != null ? (json['data'] as List).map((item) => AppBanner.fromJson(item)).toList() : null,  
    );
  }
}

