class City {
  final String cityId;
  final String provinceId;
  final String province;
  final String type;
  final String cityName;
  final String postalCode;

  City({
    required this.cityId,
    required this.provinceId,
    required this.province,
    required this.type,
    required this.cityName,
    required this.postalCode,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      cityId: json['city_id'],
      provinceId: json['province_id'],
      province: json['province'],
      type: json['type'],
      cityName: json['city_name'],
      postalCode: json['postal_code'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is City &&
          runtimeType == other.runtimeType &&
          cityId == other.cityId;

  @override
  int get hashCode => cityId.hashCode;
}
