import 'package:flutter/material.dart';
import 'package:jahit_baju/data/model/look_order.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/look_access_response.dart';
import 'package:jahit_baju/data/source/remote/response/look_order_response.dart';

class LookViewModel extends ChangeNotifier {
  ApiService apiService;

  String? _message;
  String? get message => _message;

  bool _loading = false;
  bool get loading => _loading;

  LookViewModel(this.apiService);

  Future<bool> getLookAccess(String lookId) async {
    _loading = true;
    notifyListeners();
    LookAccessResponse response = await apiService.getLookAccess(lookId);
    if (response.error) {
      _loading = false;
      notifyListeners();
      return false;
    } else {
      _loading = false;
      notifyListeners();
      return true;
    }
  }

  Future<LookOrder?> buyLook(String lookId) async {
    _loading = true;
    notifyListeners();
    LookOrderResponse response = await apiService.buyLook(lookId);
    if (response.error && response.look != null) {
      _loading = false;
      notifyListeners();
      return null;
    } else {
      _loading = false;
      notifyListeners();
      return response.look;
    }
  }
}

