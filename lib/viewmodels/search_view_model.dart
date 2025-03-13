import 'package:flutter/material.dart';
import 'package:jahit_baju/data/repository/repository.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/source/remote/response/product_response.dart';

class SearchViewModel extends ChangeNotifier {
  Repository repository;

  String? _errorMsg;
  String? get errorMsg =>_errorMsg;


  List<Product>? _productsRTW;
  List<Product>? get productsRTW => _productsRTW;

  List<Product>? _filteredRTW;
  List<Product>? get filteredRTW => _filteredRTW;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;
  
  String? _selectedTags;
  String? get selectedTags => _selectedTags;

  String? _searchQuery;
  String? get searchQuery => _searchQuery;


  SearchViewModel(this.repository);


  setSearchQuery(String? newSearchQuery){
    _searchQuery = newSearchQuery;
    notifyListeners();
  }


  setSelectedTags(String? newSelectedTags){
    _selectedTags = newSelectedTags;
    notifyListeners();
  }

  setSelectedCategory(String? newSelectedCategory){
    _selectedCategory = newSelectedCategory;
    notifyListeners();
  }


  setListOfProductRTW(List<Product> newProductRTW){
    _productsRTW = newProductRTW;
    notifyListeners();
  }


  setFilteredRTW(List<Product> newFilteredRTW){
    _filteredRTW = newFilteredRTW;
    notifyListeners();
  }

  Future<dynamic> getListProducts() async {    
    var data = await repository.getAllProduct();
    if (data is List<Product>) {
      return data;
    }else if(data is String){
      _errorMsg = data.toString();
    }
    notifyListeners();
  }

  bool sendSurvei() {
    return true;
  }
}
