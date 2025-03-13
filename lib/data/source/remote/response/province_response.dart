import 'package:jahit_baju/data/model/province.dart';

class ProvinceResponse {
  final bool error;
  String? message;
  final List<Province>? provinces;

  ProvinceResponse({
    required this.error,
    this.message,   
    this.provinces,
  });

  factory ProvinceResponse.fromJson(Map<String, dynamic> json) {
    return ProvinceResponse(
      error: json['error'],
      message: json['message'] ?? "",  
      provinces: json['data'] != null ? (json['data'] as List)
          .map((province) => Province.fromJson(province))
          .toList() : null,
    );
  }

}
