import 'package:flutter/material.dart';
import 'package:jahit_baju/data/model/order.dart';
import 'package:jahit_baju/data/model/user.dart';
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

  bool _loading = false;
  bool get loading => _loading;

  
  Address? _userAddress;
  Address? get userAddress => _userAddress;

  Shipping? _shipping;
  Shipping? get shipping => _shipping;


  Packaging? _packaging;
  Packaging? get packaging => _packaging;

  List<Shipping> _listOfShipping = [];
  List<Shipping> get listOfShipping => _listOfShipping;

  List<Packaging> _listOfPackaging = [];
  List<Packaging> get listOfPackaging => _listOfPackaging;

  int? _totalWeight;
  int? get totalWeight => _totalWeight;

  ShippingViewModel(this.apiService);

  setTotalWeight(int newTotalWeight) {
    _totalWeight = newTotalWeight;
    notifyListeners();
  }

  setShipping(Shipping newShipping) {
    _shipping = newShipping;
    notifyListeners();
  }


  setPackaging(Packaging newPackaging) {
    _packaging = newPackaging;
    notifyListeners();
  }


  Future<void> getListShippingMethod() async {
    _loading = true;
    notifyListeners();
    if (_totalWeight != null) {
      ShippingsResponse response =
          await apiService.getAllShipping(_totalWeight!);
      if (!response.error) {
        _loading = false;
        _listOfShipping = response.shippings ?? [];
        notifyListeners();
      } else {
        _errorMsg = response.message ?? ApiService.SOMETHING_WAS_WRONG_SERVER;
        _loading = false;
        _listOfShipping = [];
        notifyListeners();
      }
    } else {
      _errorMsg = "Berat produk wajib untuk kalkulasi harga pengiriman.";
      _loading = false;
      _listOfShipping = [];
      notifyListeners();
    }
  }

  Future<void> getUserAddress() async {
    _loading = true;
    notifyListeners();
    UserResponse response = await apiService.userGet();

    if (response.error) {
      _errorMsg = response.message;
      _loading = false;
      _userAddress =  response.data?.address;
      notifyListeners();
    } else {
      _loading = false;
      _userAddress =  response.data?.address;
      notifyListeners();
    }
  }

  Future<void> getListPackaging() async {
    _loading = true;
    notifyListeners();
    var data = await apiService.getAllPackaging();

    if (data is List<Packaging>) {
      _loading = false;
      _listOfPackaging = data;
      notifyListeners();
    } else if (data is String) {
      _errorMsg = data as String?;

      _loading = false;
      notifyListeners();
    } else {
      _loading = false;
      _listOfPackaging = [];
      notifyListeners();
    }
  }

  Future<Order?> createOrder(Order? order) async {
    _loading = true;
    notifyListeners();
    if (order != null) {
      OrderResponse orderResponse = await apiService.orderCreate(order);

      if (orderResponse.data is Order) {
        _loading = false;
        notifyListeners();
        return orderResponse.data;
      } else if (orderResponse.data is String) {
        _loading = false;
        notifyListeners();
        return null;
      }
    }
    return null;
  }

  Future<Order?> buyNow(Order? order, String? filename) async {
    _loading = true;
    notifyListeners();
    if (order != null) {
      OrderResponse orderResponse =
          await apiService.buyNow(order, filename: filename);
      if (orderResponse.error) {
        _errorMsg = orderResponse.message;

        _loading = false;
        notifyListeners();
        return null;
      }

      _loading = false;
      notifyListeners();
      return Order.fromJson(orderResponse.data);
    }

    _loading = false;
    notifyListeners();
    return null;
  }
}
