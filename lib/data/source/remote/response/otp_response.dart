
class OtpResponse {
  bool? error;
  String? message;
  String? token;

  OtpResponse({
    required this.error,
    this.message,   
    this.token  
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      error: json['error'],
      message: json['message'],     
      token: json['token'],     
    );
  }
}
