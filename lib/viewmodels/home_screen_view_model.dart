import 'package:flutter/material.dart';
import 'package:jahit_baju/data/source/remote/response/cart_response.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/data/model/cart.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/model/product.dart';

class HomeScreenViewModel extends ChangeNotifier {
  ApiService apiService;
  late TokenStorage tokenStorage = TokenStorage();

  String? _errorMsg;
  String? get errorMsg => _errorMsg;
  int _cartSize = 0;
  int get cartSize => _cartSize;

  HomeScreenViewModel(this.apiService);

  Future<void> getCartItemSize() async {
    String? token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    int value = 0;

    if (token != null) {
      CartResponse response = await apiService.cartGet(); 
      if (!response.error) {
        final cart = response.cart;
        if(cart != null){
          value = cart.items.length;
        }else{
          _errorMsg = ApiService.SOMETHING_WAS_WRONG;
        }        
      }else{
        _errorMsg = response.message;
      }
    }


    notifyListeners();
    _cartSize = value;
  }

  void refresh() {
    notifyListeners();
  }
}
