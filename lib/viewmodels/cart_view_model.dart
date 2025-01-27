import 'package:flutter/material.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/data/model/cart.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/source/remote/response/product_response.dart';

class CartViewModel extends ChangeNotifier {
  ApiService apiService;

  String? _errorMsg;

  String? get errorMsg => _errorMsg;

  CartViewModel(this.apiService);

  Future<Product?> getProductById(String productId) async {
    ProductResponse response = await apiService.productsGetById(productId);
    if (response.error) {
      _errorMsg = response.message;
    } else {
      return response.product!;
    }
  }

  Future<dynamic> getCart() async {
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
