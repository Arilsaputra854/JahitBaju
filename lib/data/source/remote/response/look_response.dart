
import 'package:jahit_baju/data/model/designer.dart';
import 'package:jahit_baju/data/model/look.dart';

class LookResponse {
  bool error;
  String? message;
  Look? look;

  LookResponse({
    required this.error,
    this.look,    
    this.message,
  });

  factory LookResponse.fromJson(Map<String, dynamic> json) {
    return LookResponse(
      error: json['error'] ?? false,
      message: json['message'],  
      look: json['data'] != null? Look.fromJson(json['data']) : null,    
    );
  }
}

