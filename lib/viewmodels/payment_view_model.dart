import 'package:flutter/material.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/model/cart.dart';
import 'package:jahit_baju/model/product.dart';

class PaymentViewModel extends ChangeNotifier {
  ApiService api = ApiService();

  String? _errorMsg;

  String? get errorMsg => _errorMsg;

  Future<Product> getProductById(String productId) async {

    ApiService apiService = ApiService();
    Product product = await apiService.productsGetById(productId);
    return product;
  }

}
