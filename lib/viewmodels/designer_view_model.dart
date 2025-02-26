import 'package:flutter/material.dart';
import 'package:jahit_baju/data/model/designer.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/designer_response.dart';
import 'package:jahit_baju/data/source/remote/response/login_response.dart';
import 'package:jahit_baju/util/util.dart';

class DesignerViewModel extends ChangeNotifier {  
  String? _errorMsg;
  bool _isLoading = false;

  bool? get isLoading => _isLoading;
  String? get errorMsg => _errorMsg;

  ApiService apiService;
  DesignerViewModel(this.apiService);

  Future<List<Designer>?> getDesigners()async {
    _errorMsg = null;
    DesignerResponse response = await apiService.getDesigner();
    if(response.error){      
      _errorMsg = response.message;
      notifyListeners();
      return [];
    }else{
      return response.data;
    }
  }
}
