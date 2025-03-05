import 'package:jahit_baju/data/model/user.dart';

class UserResponse {
  bool error;
  String? message;
  User? data;

  UserResponse({
    required this.error,
    this.message,
    this.data,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",
      data: json['data'] != null? User.fromJson(json['data']) :null
    );
  }
}
