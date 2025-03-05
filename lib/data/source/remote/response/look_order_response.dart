
import 'package:jahit_baju/data/model/look_order.dart';

class LookOrderResponse {
  bool error;
  String? message;
  LookOrder? look;

  LookOrderResponse({
    required this.error,
    this.look,    
    this.message,
  });

  factory LookOrderResponse.fromJson(Map<String, dynamic> json) {
    return LookOrderResponse(
      error: json['error'] ?? false,
      message: json['message'],  
      look: json['data'] != null? LookOrder.fromJson(json['data']) : null,    
    );
  }
}

