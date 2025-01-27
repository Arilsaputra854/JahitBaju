import 'package:flutter/material.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/data/model/cart.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/source/remote/response/product_response.dart';

class PaymentViewModel extends ChangeNotifier {
  ApiService apiService;

  String? _errorMsg;
  String? get errorMsg => _errorMsg;

  PaymentViewModel(this.apiService);

  Future<Product?> getProductById(String productId) async {

    ProductResponse response = await apiService.productsGetById(productId);
    if (response.error) {
      _errorMsg = response.message;
    } else {
      return response.product!;
    }
    return null;
  }

}
