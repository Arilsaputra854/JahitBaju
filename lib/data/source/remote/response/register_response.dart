
import 'package:jahit_baju/data/model/user.dart';

class RegisterResponse {  
  bool error;  
  String? message;
  User? user;

  static const String EMAIL_ALREADY_EXIST="Email already exists";

  RegisterResponse({
    required this.error,
    this.message,   
    this.user
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      error: json['error'] ?? false,
      message: json['message'],     
      user: json['data'] != null ? User.fromJson(json['data']) : null
    );
  }
}
