import 'package:flutter/material.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/model/product.dart';

class SearchViewModel extends ChangeNotifier {
  ApiService apiService = ApiService();

  String? _errorMsg;

  String? get errorMsg =>_errorMsg;

  Future<dynamic> getListProducts() async {    
    var data = await apiService.productsGet();
    if (data is List<Product>) {
      return data;
    } else if (data is String) {
      _errorMsg = data;
    }else{
      return null;
    }
  }

  bool sendSurvei() {
    return true;
  }
}
