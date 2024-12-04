
class FavoriteResponse {
  bool error;
  String? message;
  int? id;

  FavoriteResponse({
    required this.error,
    this.message,   
    this.id  
  });

  factory FavoriteResponse.fromJson(Map<String, dynamic> json) {
    return FavoriteResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",     
      id: json['data'] != null ? json['data']['id'] as int : null,     
    );
  }
}
