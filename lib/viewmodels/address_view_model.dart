import 'package:flutter/material.dart';
import 'package:jahit_baju/data/model/city.dart';
import 'package:jahit_baju/data/model/province.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/city_response.dart';
import 'package:jahit_baju/data/source/remote/response/province_response.dart';

class AddressViewModel extends ChangeNotifier {
  ApiService apiService;

  String? _errorMsg;
  String? get errorMsg => _errorMsg;

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
    print("selected city ${_selectedCity!.cityId}");
    notifyListeners();
  }

  setSelectedProvince(Province newProvince) {
    _selectedProvince = newProvince;
    print("selected province ${_selectedProvince!.provinceId}");
    notifyListeners();
  }

  Future<List<City>?> fetchListCity() async {
    if (_listOfCity == null) {
      _listOfCity = await fetchCityFromAPI();
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
      _listOfProvince = await fetchProvinceFromAPI();
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
}
