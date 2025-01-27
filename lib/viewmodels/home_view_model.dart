import 'package:flutter/material.dart';
import 'package:jahit_baju/data/repository/repository.dart';
import 'package:jahit_baju/data/model/product.dart';

class HomeViewModel extends ChangeNotifier {
  
  Repository repository;

  String? _errorMsg;
  String? get errorMsg =>_errorMsg;

  HomeViewModel(this.repository);

  Future<List<Product>?> getListProducts() async {    
    return await repository.getAllProduct();
  }

  void refresh(){
    notifyListeners();
  }
}
