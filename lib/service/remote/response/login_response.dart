class LoginResponse {
  bool error;
  String? message;
  String? token;

  LoginResponse({
    required this.error,
    this.message,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      error: json['error'] ?? false,
      message: json['message'],
      token: json['data']["token"],
    );
  }
}
