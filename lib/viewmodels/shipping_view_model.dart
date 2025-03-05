import 'package:flutter/material.dart';
import 'package:jahit_baju/data/model/order.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/shipping_response.dart';
import 'package:jahit_baju/data/source/remote/response/user_response.dart';
import 'package:jahit_baju/data/model/packaging.dart';
import 'package:jahit_baju/data/model/shipping.dart';
import 'package:jahit_baju/data/source/remote/response/order_response.dart';

class ShippingViewModel extends ChangeNotifier {
  ApiService apiService;

  String? _errorMsg;
  String? get errorMsg => _errorMsg;

  ShippingViewModel(this.apiService);

  Future<List<Shipping>?> getListShippingMethod() async {
    ShippingsResponse  response = await apiService.getAllShipping();
    if (!response.error) {
      return response.shippings;
    } else {
      _errorMsg = response.message ?? ApiService.SOMETHING_WAS_WRONG_SERVER;
      return [];
    }
  }

  Future<String?> getUserAddress() async {
    UserResponse response = await apiService.userGet();

    if(response.error){
      _errorMsg = response.message;
      notifyListeners();
    return null;
    }else{
      return response.data?.address;
    }
  }

  Future<dynamic> getListPackaging() async {
    var data = await apiService.getAllPackaging();

    if (data is List<Packaging>) {
      return data;
    } else if (data is String) {
      _errorMsg = data as String?;
    } else {
      return [];
    }
  }

  Future<Order?> createOrder(Order? order) async {
    if (order != null) {

      OrderResponse orderResponse = await apiService.orderCreate(order);

      if (orderResponse.data is Order) {
        return orderResponse.data;
      } else if (orderResponse.data is String) {
        return null;
      }
    }
    return null;
  }

  Future<Order?> buyNow(Order? order, String? filename) async {
    
    if (order != null) {

      OrderResponse orderResponse = await apiService.buyNow(order,filename: filename);
      if (orderResponse.error) {        
        _errorMsg = orderResponse.message;
        return null;
      }
      return Order.fromJson(orderResponse.data);
    }
    _errorMsg = "Terjadi Kesalahan";
    return null;
  }
}
