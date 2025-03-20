import 'package:flutter/material.dart';
import 'package:jahit_baju/data/model/city.dart';
import 'package:jahit_baju/data/model/province.dart';
import 'package:jahit_baju/data/model/user.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/city_response.dart';
import 'package:jahit_baju/data/source/remote/response/province_response.dart';
import 'package:jahit_baju/data/source/remote/response/user_response.dart';

class AddressViewModel extends ChangeNotifier {
  ApiService apiService;

  String? _errorMsg;
  String? get errorMsg => _errorMsg;

  bool _loading = false;
  bool get loading => _loading;


  int? _postalCode;
  int? get postalCode => _postalCode;

  City? _selectedCity;
  City? get selectedCity => _selectedCity;

  Province? _selectedProvince;
  Province? get selectedProvince => _selectedProvince;

  List<City>? _listOfCity;
  List<City>? get listOfCity => _listOfCity;

  List<Province>? _listOfProvince;
  List<Province>? get listOfProvince => _listOfProvince;

  AddressViewModel(this.apiService);

  setSelectedCity(City newCity) {
    _selectedCity = newCity;
    notifyListeners();
  }

  setSelectedProvince(Province newProvince) {
    _selectedProvince = newProvince;
    notifyListeners();
  }


  setPostalCode(int newPostalCode) {
    _postalCode = newPostalCode;
    notifyListeners();
  }

  Future<List<City>?> fetchListCity() async {
    if (_listOfCity == null) {
      _loading = true;
      notifyListeners();
      _listOfCity = await fetchCityFromAPI();

      _loading = false;
      notifyListeners();
    }

    return _listOfCity;
  }

  Future<List<City>?> fetchCityFromAPI() async {
    CityResponse response = await apiService.getListCity();
    if (response.error) {
      _errorMsg = ApiService.SOMETHING_WAS_WRONG;
    } else {
      return response.cities!;
    }
  }

  Future<List<Province>?> fetchListProvince() async {
    if (_listOfProvince == null) {
      _loading = true;
      notifyListeners();
      _listOfProvince = await fetchProvinceFromAPI();

      _loading = false;
      notifyListeners();
    }

    return _listOfProvince;
  }

  Future<List<Province>?> fetchProvinceFromAPI() async {
    ProvinceResponse response = await apiService.getListProvinces();
    if (response.error) {
      _errorMsg = ApiService.SOMETHING_WAS_WRONG;
    } else {
      return response.provinces!;
    }
  }

  Future<User?> updateAddressUser(
      String newAddress, AddressViewModel viewmodel) async {
    Address address = new Address(
        streetAddress: newAddress,
        city: int.parse(viewmodel.selectedCity!.cityId),
        province: int.parse(viewmodel.selectedProvince!.provinceId),
        postalCode: int.parse(viewmodel.selectedCity!.postalCode));
    UserResponse response =
        await apiService.userUpdate(null, null, null, null, address, null);
    if (response.error) {
      _errorMsg = response.message;
      notifyListeners();
    } else {
      return response.data!;
    }
    return null;
  }
}
