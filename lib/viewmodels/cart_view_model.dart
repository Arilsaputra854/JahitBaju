import 'package:flutter/material.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/model/cart.dart';
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/service/remote/response/product_response.dart';

class CartViewModel extends ChangeNotifier {
  ApiService api = ApiService();

  String? _errorMsg;

  String? get errorMsg => _errorMsg;

  Future<Product?> getProductById(String productId) async {
    ApiService apiService = ApiService();
    ProductResponse response = await apiService.productsGetById(productId);
    if (response.error) {
      _errorMsg = response.message;
    } else {
      return response.product!;
    }
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
          Product? product = await getProductById(cartItem.productId);
          if (product != null) {
            if (product!.type == type) {
              result.add(MapEntry(cartItem, product));
            }
          }else{
            _errorMsg = "Terjadi Kesalahan";
          }
        } catch (e) {
          _errorMsg = "Error fetching product ${cartItem.productId}: $e";
        }
      }
    }

    return result.isNotEmpty ? result : null;
  }
}
