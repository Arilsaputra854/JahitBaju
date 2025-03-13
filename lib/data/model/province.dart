class Province {
  final String provinceId;
  final String provinceName;

  Province({
    required this.provinceId,
    required this.provinceName,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      provinceId: json['province_id'],
      provinceName: json['province'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'province_id': provinceId,
      'province': provinceName,
    };
  }
}
