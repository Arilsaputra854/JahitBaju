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

  String? _selectedCity;
  String? get selectedCity => _selectedCity;

  String? _district;
  String? get district => _district;


  String? _village;
  String? get village => _village;

  String? _selectedProvince;
  String? get selectedProvince => _selectedProvince;

  List<City>? _listOfCity;
  List<City>? get listOfCity => _listOfCity;

  List<Province>? _listOfProvince;
  List<Province>? get listOfProvince => _listOfProvince;

  AddressViewModel(this.apiService);

  init(){
    _selectedCity = null;
    _selectedProvince = null;
    _village = null;
    _district = null;
    _postalCode = null;
    _errorMsg = null;
  }

  setSelectedCity(String newCity) {
    _selectedCity = newCity;
    notifyListeners();
  }

  setSelectedProvince(String newProvince) {
    _selectedProvince = newProvince;
    notifyListeners();
  }


  setSelectedDistrict(String newDistrict) {
    _district = newDistrict;
    notifyListeners();
  }


  setSelectedVillage(String newVillage) {
    _village = newVillage;
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
        city: viewmodel.selectedCity,
        village: viewmodel.village,
        district: viewmodel.district,
        province: viewmodel.selectedProvince,
        postalCode: viewmodel.postalCode!);
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
