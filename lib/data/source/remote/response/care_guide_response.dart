class CareGuideResponse {
  bool error;
  String? message;
  String? data;

  CareGuideResponse({
    required this.error,
    this.message,
    this.data,
  });

  factory CareGuideResponse.fromJson(Map<String, dynamic> json) {
    return CareGuideResponse(
      error: json['error'] ?? false,
      message: json['message'],
      data: json['data']['data'],
    );
  }
}
