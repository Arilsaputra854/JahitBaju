
class SurveiResponse {
  bool error;
  String? message;
  String? question1;
  String? question2;
  String? question3;
  String? id;

  SurveiResponse({
    required this.error,
    this.message,   
    this.question1,   
    this.question2,   
    this.question3,   
    this.id  
  });

  factory SurveiResponse.fromJson(Map<String, dynamic> json) {
    return SurveiResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",    
      question1: json['data'] != null ? json['data']['question_1']: null,      
      question2: json['data'] != null ? json['data']['question_2']: null,      
      question3: json['data'] != null ? json['data']['question_3'] : null,      
      id: json['data'] != null ? json['data']['id'] : null,     
    );
  }
}
