import 'package:flutter/material.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/model/cart.dart';
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/service/remote/response/product_response.dart';

class PaymentViewModel extends ChangeNotifier {
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

}
