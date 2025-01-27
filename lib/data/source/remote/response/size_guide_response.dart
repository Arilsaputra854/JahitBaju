class SizeGuideResponse {
  bool error;
  String? data;

  SizeGuideResponse({
    required this.error,
    this.data,
  });

  factory SizeGuideResponse.fromJson(Map<String, dynamic> json) {
    return SizeGuideResponse(
      error: json['error'] ?? false,
      data: json['data']['data'],
    );
  }
}
