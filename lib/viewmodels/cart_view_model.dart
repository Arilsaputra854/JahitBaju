import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:jahit_baju/data/model/look.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/cart_response.dart';
import 'package:jahit_baju/data/source/remote/response/look_response.dart';
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

  Future<Cart?> getCart() async {
    CartResponse response = await apiService.cartGet();
    if (!response.error) {
      return response.cart;
    } else  {
      _errorMsg = response.message;
    }
    return null;
  }

  Future<List<MapEntry<CartItem, Product>>?> getCartItems(
      List<CartItem>? cartItems) async {
    List<MapEntry<CartItem, Product>> result = [];

    if (cartItems != null) {
      for (var cartItem in cartItems) {
        try {
          Product? product = await getProductById(cartItem.productId!);
          if (product != null) {            
              result.add(MapEntry(cartItem, product));
          }else{
            _errorMsg = ApiService.SOMETHING_WAS_WRONG;
          }
        } catch (e,stackTrace) {
        FirebaseCrashlytics.instance.recordError(e, stackTrace);
          _errorMsg = "Error fetching product ${cartItem.productId}: $e";
        }
      }
    }

    return result.isNotEmpty ? result : null;
  }


  Future<List<MapEntry<CartItem, Look>>?> getLooksCartItems(
      List<CartItem>? cartItems) async {
    List<MapEntry<CartItem, Look>> result = [];

    if (cartItems != null) {
      for (var cartItem in cartItems) {
        try {
          Look? look = await getLook(cartItem.lookId!);
          if (look != null) {            
              result.add(MapEntry(cartItem, look));
          }else{
            _errorMsg =  ApiService.SOMETHING_WAS_WRONG;
          }
        } catch (e,stackTrace) {
        FirebaseCrashlytics.instance.recordError(e, stackTrace);
          _errorMsg = "Error fetching product ${cartItem.productId}: $e";
        }
      }
    }

    return result.isNotEmpty ? result : null;
  }


  Future<Look?> getLook(String lookId) async {
    LookResponse response = await apiService.getLookGetById(lookId);
    if (response.error) {
            _errorMsg =  ApiService.SOMETHING_WAS_WRONG;
    } else {
      return response.look!;
    }
  }
}
