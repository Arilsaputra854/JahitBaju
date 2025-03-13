import 'package:flutter/material.dart';
import 'package:jahit_baju/data/repository/repository.dart';
import 'package:jahit_baju/data/model/product.dart';

class HomeViewModel extends ChangeNotifier {
  
  Repository repository;


  List<String>? _tags;
  List<String>? get tags =>_tags;


  List<Product>? _products;
  List<Product>? get products =>_products;

  String? _errorMsg;
  String? get errorMsg =>_errorMsg;

  HomeViewModel(this.repository);

  setProducts(List<Product> newProducts){
    _products = newProducts;
    notifyListeners();
  }


  setTags(List<String> newTags){
    _tags = newTags;
    notifyListeners();
  }

  Future<List<Product>?> getListProducts() async {    
    return await repository.getAllProduct();
  }

  void refresh(){
    notifyListeners();
  }
}
