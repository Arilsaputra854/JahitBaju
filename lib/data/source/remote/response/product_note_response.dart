class ProductNoteResponse {
  bool error;
  String? message;
  String? data;
  int? type;

  ProductNoteResponse({
    required this.error,
    this.message,
    this.data,
    this.type
  });

  factory ProductNoteResponse.fromJson(Map<String, dynamic> json) {
    return ProductNoteResponse(
      error: json['error'] ?? false,
      message: json['message'],
      data: json['data']['data'],
      type : json['data']['type']
    );
  }
}
