import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/model/favorite.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/care_guide_response.dart';
import 'package:jahit_baju/data/source/remote/response/favorite_response.dart';
import 'package:jahit_baju/data/source/remote/response/product_note_response.dart';
import 'package:jahit_baju/data/source/remote/response/size_guide_response.dart';

class ProductViewModel extends ChangeNotifier {
  ApiService apiService;

  String? _selectedSize;
  String? get selectedSize => _selectedSize;

  String? _productNotes;
  String? get productNotes => _productNotes;

  String? _careGuides;
  String? get careGuides => _careGuides;

  String? _sizeGuide;
  String? get sizeGuide => _sizeGuide;

  bool _loading = false;
  bool get loading => _loading;

  Product? _product;
  Product? get product => _product;

  int? _favoriteId;
  int? get favoriteId => _favoriteId;

  bool? _isProductFavorited;
  bool? get isProductFavorited => _isProductFavorited;

  String? _errorMsg;
  String? get errorMsg => _errorMsg;

  ProductViewModel(this.apiService);

  init(){
    _product = null;
    _favoriteId = null;
    _isProductFavorited = false;
    _selectedSize = null;
  }

  setProduct(Product newProduct) {
    _selectedSize = null;
    _product = newProduct;
    notifyListeners();
  }

  setSelectedSize(String newSelectedSize) {
    _selectedSize = newSelectedSize;
    notifyListeners();
  }

  setFavorite(bool favorited) {
    _isProductFavorited = favorited;
    notifyListeners();
  }

  Future<void> addOrRemoveProductFavorite() async {
    if (_product == null) {
      Fluttertoast.showToast(msg: "Produk tidak valid.");
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      if (_isProductFavorited == true) {
        // Hapus dari favorit
        if (_favoriteId != null) {
          FavoriteResponse response =
              await apiService.favoriteDelete(_favoriteId!);

          if (response.error) {
            _errorMsg = response.message;
            Fluttertoast.showToast(msg: "Gagal menghapus dari favorit.");
          } else {
            _isProductFavorited = false;
            _favoriteId = null;
            Fluttertoast.showToast(msg: "Berhasil menghapus dari favorit.");
          }
        }
      } else {
        // Tambah ke favorit
        Favorite favorite =
            Favorite(productId: _product!.id, lastUpdate: DateTime.now());
        FavoriteResponse response = await apiService.favoriteAdd(favorite);

        if (response.error) {
          _errorMsg = response.message;
          Fluttertoast.showToast(msg: "Gagal menambahkan ke favorit.");
        } else {
          _isProductFavorited = true;
          _favoriteId = response.id; // Simpan ID favorit yang baru ditambahkan
          Fluttertoast.showToast(msg: "Berhasil menambahkan ke favorit.");
        }
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      _errorMsg = "Terjadi kesalahan. Coba lagi.";
      Fluttertoast.showToast(msg: _errorMsg!);
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> getFavoriteStatus() async {
    _loading = true;
    notifyListeners;
    if (_product != null && _isProductFavorited == null) {
      FavoritesResponse response = await apiService.getUserFavorites();

      if (response.error) {
        _errorMsg = response.message;
        _isProductFavorited = false;

        _loading = false;
        notifyListeners();
        return false;
      }
      for (var favorite in response.favorites!) {
        if (favorite.productId == _product!.id) {
          _favoriteId = favorite.id;
          _isProductFavorited = true;

          _loading = false;
          notifyListeners();
          return true;
        } else {
          _isProductFavorited = false;

          _loading = false;
          notifyListeners();
          return false;
        }
      }
      notifyListeners();
      return false;
    } else {
      _errorMsg = "Tidak dapat memuat produk";

      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> getSizeGuide() async {
    if (_sizeGuide == null) {
      _loading = true;
      notifyListeners();
      SizeGuideResponse response = await apiService.sizeGuide();

      if (response.error) {
        _loading = false;
        _errorMsg = response.message ?? ApiService.SOMETHING_WAS_WRONG;
        notifyListeners();
      } else {
        _sizeGuide = response.data!;
        _loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> getNoteProduct(int type) async {
    if (_productNotes == null) {
      ProductNoteResponse response = await apiService.getNoteProduct(type);

      if (response.error) {
        _errorMsg = response.message ?? ApiService.SOMETHING_WAS_WRONG;
        notifyListeners();
      } else {
        _productNotes = response.data!;
        notifyListeners();
      }
    }
  }

  Future<void> getCareGuide() async {
    if (_careGuides == null) {
      CareGuideResponse response = await apiService.getCareGuide();

      if (response.error) {
        _errorMsg = response.message ?? ApiService.SOMETHING_WAS_WRONG;
        notifyListeners();
      } else {
        _careGuides = response.data!;
        notifyListeners();
      }
    }
  }
}
