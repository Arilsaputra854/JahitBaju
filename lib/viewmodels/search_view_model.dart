import 'package:flutter/material.dart';
import 'package:jahit_baju/data/repository/repository.dart';
import 'package:jahit_baju/data/model/product.dart';

class SearchViewModel extends ChangeNotifier {
  Repository repository;

  String? _errorMsg;
  String? get errorMsg => _errorMsg;
  List<Product> _productsRTW = [];
  List<Product>? get productsRTW => _productsRTW;
  List<Product> _filteredRTW = [];
  List<Product>? get filteredRTW => _filteredRTW;

  List<String> _tags = [];
  List<String> get tags => _tags;

  List<String> _categories = [];
  List<String> get categories => _categories;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  String? _selectedTags;
  String? get selectedTags => _selectedTags;

  String? _searchQuery;
  String? get searchQuery => _searchQuery;

  SearchViewModel(this.repository) {
    _init();
  }

  void _init() {
    _productsRTW = [];
    _filteredRTW = [];
    _selectedCategory = null;
    _selectedTags = null;
    _searchQuery = null;
  }

  void setCategories(List<String> newCategories) {
    if (_categories != newCategories) {
      _categories = newCategories;
      notifyListeners();
    }
  }

  void setTags(List<String> newTags) {
    if (_tags != newTags) {
      _tags = newTags;
      notifyListeners();
    }
  }

  void setSearchQuery(String? newSearchQuery) {
    if (_searchQuery != newSearchQuery) {
      _searchQuery = newSearchQuery;
      notifyListeners();
      filterProducts();

    }
  }

  setSelectedTags(String? newSelectedTags) {
    _selectedTags = newSelectedTags;
    notifyListeners();
  }

  setSelectedCategory(String? newSelectedCategory) {
    _selectedCategory = newSelectedCategory;
    notifyListeners();
  }

  setFilteredRTW(List<Product> newFilteredRTW) {
    _filteredRTW = newFilteredRTW;
    notifyListeners();
  }
  void filterProducts() {
  _filteredRTW = _productsRTW.where((product) {
    final matchesCategory = _selectedCategory == null ||
        (product.category?.contains(_selectedCategory) ?? false);
    final matchesTag = _selectedTags == null ||
        (product.tags.contains(_selectedTags));
    final matchesQuery = _searchQuery == null ||
        product.name.toLowerCase().contains(_searchQuery!.toLowerCase());

    return matchesCategory && matchesTag && matchesQuery;
  }).toList();

  notifyListeners();
}


  Future<void> getListProducts() async {
    try {
      if (_productsRTW.isEmpty) {
        var data = await repository.getAllProduct();
        if (data != null) {
          _productsRTW = data;
          _tags =
              _productsRTW.expand((product) => product.tags).toSet().toList();

          _categories = _productsRTW
    .map((product) => product.category ?? [])
    .expand((category) => category)
    .toSet()
    .toList();

        } else {
          _productsRTW = [];
        }
      }
      _errorMsg = null;
    } catch (e) {
      _errorMsg = "Failed to load products: ${e.toString()}";
    } finally {
      notifyListeners();
    }
  }
}
