import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:jahit_baju/data/model/favorite.dart';
import 'package:jahit_baju/data/model/look.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/care_guide_response.dart';
import 'package:jahit_baju/data/source/remote/response/favorite_response.dart';
import 'package:jahit_baju/data/source/remote/response/product_note_response.dart';
import 'package:jahit_baju/data/source/remote/response/size_guide_response.dart';

class CustomProductViewModel extends ChangeNotifier {
  ApiService apiService;

  Look? _look;
  Look? get look => _look;

  String? _currentSVG;
  String? get currentSVG => _currentSVG;

  Map<String, String> _currentFeatureColor = {};
  Map<String, String> get currentFeatureColor => _currentFeatureColor;

  String? _currentFeature;
  String? get currentFeature => _currentFeature;

  String? _currentColor;
  String? get currentColor => _currentColor;

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

  String? _loadingText;
  String? get loadingText => _loadingText;

  Product? _product;
  Product? get product => _product;

  int? _favoriteId;
  int? get favoriteId => _favoriteId;

  bool? _isProductFavorited;
  bool? get isProductFavorited => _isProductFavorited;

  String? _errorMsg;
  String? get errorMsg => _errorMsg;

  CustomProductViewModel(this.apiService);

  void resetData() {
    _look = null;
    _currentColor = null;
    _currentFeatureColor = {};
    _currentSVG = null;
    _currentFeature = null;
    _careGuides = null;
    _sizeGuide = null;
    _selectedSize = null;
    _product = null;
    _favoriteId = null;
    _isProductFavorited = null;
    _errorMsg = null;
    notifyListeners();
  }

  setCurrentFeature(String newFeature) {
    _currentFeature = newFeature;
    notifyListeners();
  }

  setLook(Look newLook) {
    if (_look == null) {
      _look = newLook;
      notifyListeners();
    }
  }

  setCurrentFeatureColor(Map<String, String> newCurrentFeatureColor) {
    _currentFeatureColor = newCurrentFeatureColor;
    notifyListeners();
  }

  setCurrentColor(String newCurrentColor) {
    _currentColor = newCurrentColor;
    notifyListeners();
  }

  setCurrentSVG(String newCurrentSVG) {
    _currentSVG = newCurrentSVG;
    notifyListeners();
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

  Future<void> fetchSvg() async {
    if (_currentSVG == null) {

      if (look != null) {
        final response = await http.get(Uri.parse(look!.designUrl));
        if (response.statusCode == 200) {
          _currentSVG = response.body;
          notifyListeners();
        } else {
          _errorMsg = "Tidak dapat memuat desain, silakan coba lagi nanti.";
          notifyListeners();
        }
      } else {
        _errorMsg = "Tidak dapat memuat desain, silakan coba lagi nanti.";
        notifyListeners();
      }
    }
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
    } catch (e) {
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
      _loadingText = "Memuat panduan ukuran";
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
      _loading = true;
      _loadingText = "Memuat catatan produk";
      notifyListeners();
      ProductNoteResponse response = await apiService.getNoteProduct(type);

      if (response.error) {
        _loading = false;
        _errorMsg = response.message ?? ApiService.SOMETHING_WAS_WRONG;
        notifyListeners();
      } else {
        _loading = false;
        _productNotes = response.data!;
        notifyListeners();
      }
    }
  }

  Future<void> getCareGuide() async {
    if (_careGuides == null) {
      _loadingText = "Memuat panduan perawatan";
      _loading = true;
      _selectedSize = null;
      notifyListeners();
      CareGuideResponse response = await apiService.getCareGuide();

      if (response.error) {
        _loading = false;
        _errorMsg = response.message ?? ApiService.SOMETHING_WAS_WRONG;
        notifyListeners();
      } else {
        _loading = false;
        _careGuides = response.data!;
        notifyListeners();
      }
    }
  }
}
