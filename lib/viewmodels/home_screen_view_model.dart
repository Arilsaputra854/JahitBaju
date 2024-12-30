import 'package:flutter/material.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/model/cart.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/model/product.dart';

class HomeScreenViewModel extends ChangeNotifier {
  ApiService apiService = ApiService();
  late TokenStorage tokenStorage = TokenStorage();

  String? _errorMsg;

  String? get errorMsg => _errorMsg;

  Future<int> getCartItemSize() async {
  String? token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

  int value = 0;
  

  // if (token != null) {
  //   var response = await apiService.cartGet(); // Tunggu hasilnya
  //   if (response is Cart) {
  //     value = response.items.length;
  //   }
  // }

  notifyListeners();
  return value;
}


  void refresh() {
    notifyListeners();
  }
}
