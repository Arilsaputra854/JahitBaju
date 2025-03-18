class SizeGuideResponse {
  bool error;
  String? message;
  String? data;

  SizeGuideResponse({
    required this.error,
    this.message,
    this.data,
  });

  factory SizeGuideResponse.fromJson(Map<String, dynamic> json) {
    return SizeGuideResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? null,
      data: json['data']['data'],
    );
  }
}
