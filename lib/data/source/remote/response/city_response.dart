import 'package:jahit_baju/data/model/city.dart';

class CityResponse {
  bool error;
  String? message;
  List<City>? cities;

  CityResponse({
    required this.error,
    this.message,
    this.cities,
  });

  factory CityResponse.fromJson(Map<String, dynamic> json) {
    return CityResponse(
      error: json['error'] ?? false,
      message: json['message'],
      cities: json['data'] != null
          ? (json['data'] as List).map((item) => City.fromJson(item)).toList()
          : null,
    );
  }
}
