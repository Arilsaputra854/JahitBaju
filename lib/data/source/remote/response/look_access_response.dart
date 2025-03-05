
import 'package:jahit_baju/data/model/look_access.dart';

class LookAccessResponse {
  bool error;
  String? message;
  LookAccess? lookAccess;

  LookAccessResponse({
    required this.error,
    this.lookAccess,    
    this.message,
  });

  factory LookAccessResponse.fromJson(Map<String, dynamic> json) {
    return LookAccessResponse(
      error: json['error'] ?? false,
      message: json['message'],  
      lookAccess: json['data'] != null? LookAccess.fromJson(json['data']) : null,    
    );
  }
}

