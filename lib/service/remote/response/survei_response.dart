
class SurveiResponse {
  bool error;
  String? message;
  int? id;

  SurveiResponse({
    required this.error,
    this.message,   
    this.id  
  });

  factory SurveiResponse.fromJson(Map<String, dynamic> json) {
    return SurveiResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",     
      id: json['data'] != null ? json['data']['id'] as int : null,     
    );
  }
}
