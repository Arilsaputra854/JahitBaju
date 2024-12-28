import 'package:flutter/material.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/model/product.dart';

class HomeViewModel extends ChangeNotifier {
  ApiService apiService = ApiService();

  String? _errorMsg;

  String? get errorMsg =>_errorMsg;

  Future<dynamic> getListProducts() async {
    ApiService apiService = ApiService();
    var data = await apiService.productsGet();
    if (data is List<Product>) {
      return data;
    } else if (data is String) {
      _errorMsg = data;
    }else{
      return null;
    }
  }

  void refresh(){
    notifyListeners();
  }
}
