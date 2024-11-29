import 'package:flutter/material.dart';
import 'package:jahit_baju/api/api_service.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/model/cart.dart';
import 'package:jahit_baju/model/product.dart';

class CartViewModel extends ChangeNotifier {
  ApiService api = ApiService();

  String? _errorMsg;

  String? get errorMsg => _errorMsg;

  Future<Product> getProductById(String productId) async {

    ApiService apiService = ApiService();
    Product product = await apiService.productsGetById(productId);
    return product;
  }

  Future<dynamic> getCart() async {

    ApiService apiService = ApiService();
    var data = await apiService.cartGet();
    if (data is Cart) {
      return data;
    } else if (data is String) {
      _errorMsg = data;
    }
    return null;
  }

  Future<List<MapEntry<CartItem, Product>>?> getCartItems(
      List<CartItem>? cartItems, int type) async {
    List<MapEntry<CartItem, Product>> result = [];

    if (cartItems != null) {
      for (var cartItem in cartItems) {
        try {
          Product product = await getProductById(cartItem.productId);
          if (product.type == type) {
            result.add(MapEntry(cartItem, product));
          }
        } catch (e) {
          print("Error fetching product ${cartItem.productId}: $e");
        }
      }
    }

    return result.isNotEmpty? result : null;
  }
}
