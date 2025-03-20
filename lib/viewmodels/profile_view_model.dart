import 'package:flutter/material.dart';
import 'package:jahit_baju/data/model/user.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/user_response.dart';

class ProfileViewModel extends ChangeNotifier {
  ApiService apiService;

  String? _errorMsg;
  String? get errorMsg => _errorMsg;

  bool _onEdit = false;
  bool get onEdit => _onEdit;

  bool _enabled = false;
  bool get enable => _enabled;

  User? _user;
  User? get user => _user;

  ProfileViewModel(this.apiService);


  init() {
    _user = null;
    _onEdit = false;
    _enabled = false;
    notifyListeners();
  }


  setUserData(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  setEnable() {
    _enabled = !_enabled;
    notifyListeners();
  }

  setOnEdit() {
    _onEdit = !_onEdit;
    notifyListeners();
  }

  Future<void> loadUserFromDatabase() async {
    UserResponse response = await apiService.userGet();

    if (!response.error) {
      _user = response.data!;
      notifyListeners();
    } else {
      _user = User(
          email: "email",
          name: "name",
          password: "password",
          emailVerified: false);
      notifyListeners();
    }
  }
}
