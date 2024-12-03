

import 'package:flutter/material.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/model/packaging.dart';
import 'package:jahit_baju/model/shipping.dart';
import 'package:jahit_baju/model/user.dart';

class ShippingViewModel extends ChangeNotifier{
  ApiService api = ApiService();
  final TokenStorage _tokenStorage = TokenStorage();
  
  String? _errorMsg;
  String? get errorMsg => _errorMsg;


  Future<dynamic> getListShippingMethod() async {
    
    ApiService apiService = ApiService();
    var data = await apiService.shippingGet();
    if (data is List<Shipping>) {
      return data;
    } else if (data is String) {
      _errorMsg = data;
    }else{
      return null;
    }
  }


  Future<dynamic> getUserAddress() async {
    
    String? token = await _tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    ApiService apiService = ApiService();
    var data = await apiService.userGet(token!);
    if (data is User) {
      return data.address;
    } else if (data is String) {
      _errorMsg = data;
    }else{
      return null;
    }
  }


  Future<dynamic> getListPackaging() async {
    
    ApiService apiService = ApiService();
    var data = await apiService.packagingGet();

    if (data is List<Packaging>) {      
    return data;
    } else if (data is String) {
      _errorMsg = data as String?;
    }else{
      return null;
    }
  }

}