
class CartResponse {
  bool error;
  String? message;
  dynamic data;

  CartResponse({
    required this.error,
    this.message,   
    this.data
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",     
      data: json['data']   ?? ""     
    );
  }
}
