
class OrderResponse {
  bool error;
  String? message;
  dynamic data;

  OrderResponse({
    required this.error,
    this.message,   
    this.data
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",     
      data: json['data'] ?? ""     
    );
  }
}
