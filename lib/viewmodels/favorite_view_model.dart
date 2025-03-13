
import 'package:flutter/material.dart';
import 'package:jahit_baju/data/model/city.dart';
import 'package:jahit_baju/data/model/favorite.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/model/province.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/city_response.dart';
import 'package:jahit_baju/data/source/remote/response/favorite_response.dart';
import 'package:jahit_baju/data/source/remote/response/product_response.dart';
import 'package:jahit_baju/data/source/remote/response/province_response.dart';

class FavoriteViewModel extends ChangeNotifier {
  ApiService apiService;

  String? _errorMsg;
  String? get errorMsg => _errorMsg;


  FavoriteViewModel(this.apiService);



  Future<List<Favorite>> getFavorite() async {
    FavoritesResponse response = await apiService.getUserFavorites();
    if(response.error){
      _errorMsg = response.message!;
      notifyListeners();
    }

    return response.favorites!;
  }

  Future<Product?> getProduct(String productId) async {
    ProductResponse response = await apiService.productsGetById(productId);
    if (response.error) {
       _errorMsg =  response.message!;
       notifyListeners();
    } else {
      return response.product!;
    }
  }
}
