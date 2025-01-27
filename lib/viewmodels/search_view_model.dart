import 'package:flutter/material.dart';
import 'package:jahit_baju/data/repository/repository.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/source/remote/response/product_response.dart';

class SearchViewModel extends ChangeNotifier {
  Repository repository;

  String? _errorMsg;
  String? get errorMsg =>_errorMsg;

  SearchViewModel(this.repository);

  Future<dynamic> getListProducts() async {    
    var data = await repository.getAllProduct();
    if (data is List<Product>) {
      return data;
    }else if(data is String){
      _errorMsg = data.toString();
    }
  }

  bool sendSurvei() {
    return true;
  }
}
