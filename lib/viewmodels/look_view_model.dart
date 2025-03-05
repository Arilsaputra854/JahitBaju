import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:jahit_baju/data/model/look.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/cart_response.dart';
import 'package:jahit_baju/data/source/remote/response/look_access_response.dart';
import 'package:jahit_baju/data/source/remote/response/look_response.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/data/model/cart.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/source/remote/response/product_response.dart';

class LookViewModel extends ChangeNotifier {
  ApiService apiService;

  String? _message;
  String? get message => _message;

  LookViewModel(this.apiService);

  Future<bool> getLookAccess(String lookId) async {
    LookAccessResponse response = await apiService.getLookAccess(lookId);
    if (response.error && response.lookAccess != null) {
            _message =  ApiService.SOMETHING_WAS_WRONG;
        return false;
    } else {
      return true;
    }
  }
}
