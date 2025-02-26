
import 'package:jahit_baju/data/model/designer.dart';

class DesignerResponse {
  bool error;
  String? message;
  List<Designer>? data;

  DesignerResponse({
    required this.error,
    this.data,    
    this.message,
  });

  factory DesignerResponse.fromJson(Map<String, dynamic> json) {
    return DesignerResponse(
      error: json['error'] ?? false,
      message: json['message'],  
      data: json['data'] != null
          ? (json['data'] as List).map((item) => Designer.fromJson(item)).toList()
          : null,    
    );
  }
}

