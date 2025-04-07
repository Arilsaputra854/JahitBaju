import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/model/customization_feature.dart';
import 'package:jahit_baju/data/model/feature_order.dart';
import 'package:jahit_baju/data/repository/repository.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/customization_feature_response.dart';
import 'package:jahit_baju/data/source/remote/response/feature_response.dart';
import 'package:jahit_baju/data/source/remote/response/user_response.dart';

class HomeViewModel extends ChangeNotifier {
  Repository repository;

  List<String>? _tags;
  List<String>? get tags => _tags;

  List<Product>? _products;
  List<Product>? get products => _products;

  CustomizationAccess? _customizationAccess;
  CustomizationAccess? get customizationAccess => _customizationAccess;

  String? _errorMsg;
  String? get errorMsg => _errorMsg;

  bool _customAccess = false;
  bool get customAccess => _customAccess;

  bool _loading = false;
  bool get loading => _loading;

  ApiService apiService;

  HomeViewModel(this.repository, this.apiService);

  setProducts(List<Product> newProducts) {
    _products = newProducts;
    notifyListeners();
  }

  setTags(List<String> newTags) {
    _tags = newTags;
    notifyListeners();
  }

  Future<void> getListProducts() async {
    _products = await repository.getAllProduct();
    _tags = _products?.expand((product) => product.tags).toSet().toList();

    notifyListeners();
  }

  Future<void> getAccessCustom() async {
    UserResponse response = await apiService.userGet();
    if (response.error) {
      _errorMsg = response.message ?? ApiService.SOMETHING_WAS_WRONG;
      notifyListeners();
    } else {
      _customAccess = response.data!.customAccess;
      notifyListeners();
    }
  }

  void getCustomizationFeature() async {
    CustomizationAccessResponse response =
        await apiService.getCustomizationFeature();
    if (!response.error && response.customizationAccess != null) {
      _customizationAccess = response.customizationAccess!;
      notifyListeners();
    } else {
      Fluttertoast.showToast(msg: ApiService.SOMETHING_WAS_WRONG);
      _customizationAccess = null;
      notifyListeners();
    }
  }

  Future<FeatureOrder?> buyFeature() async {
    _loading = true;
    notifyListeners();
    BuyFeatureResponse response = await apiService.buyCostumizationFeature();
    if (response.error && response.data != null) {
      _loading = false;
      _errorMsg = response.message ?? ApiService.SOMETHING_WAS_WRONG;
      notifyListeners();
      return null;
    } else {
      _loading = false;
      notifyListeners();
      return response.data!;
    }
  }

  void refresh() {
    notifyListeners();
  }
}
