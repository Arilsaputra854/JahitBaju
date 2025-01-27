
import '../../../model/packaging.dart';

class PackagingResponse {
  bool error;
  String? message;
  Packaging? packaging;

  PackagingResponse({
    required this.error,
    this.message,   
    this.packaging  
  });

  factory PackagingResponse.fromJson(Map<String, dynamic> json) {
    return PackagingResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",     
      packaging: json['data'] != null ? Packaging.fromJson(json['data']) : null
    );
  }
}
