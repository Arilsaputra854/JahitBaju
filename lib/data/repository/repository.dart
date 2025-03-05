import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/source/local/db/db_helper.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/product_response.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:logger/web.dart';

class Repository {
  ApiService apiService;
  final _dbHelper = DatabaseHelper();
  Logger logger = Logger();

  Repository(this.apiService);

  Future<List<Product>?> getAllProduct() async {
    List<Product>? cacheProduct = await _dbHelper.getProductCache();
    logger.d("Repository Product :${json.encode(cacheProduct)}");

    if (cacheProduct != null) {
      DateTime? latestDateCache;

      for (Product product in cacheProduct) {
        DateTime lastUpdate = DateTime.parse(product.lastUpdate);
        if (latestDateCache == null || lastUpdate.isAfter(latestDateCache)) {
          latestDateCache = lastUpdate;
        }
      }
      if (await checkInternetConnection()) {
        ProductLatestResponse response =
            await apiService.productsGetByLastUpdate();
        if (response.error) {
          logger.d(
              "Repository Product: Terjadi kesalahan mengecek latest produk");
        } else {
          DateTime lastUpdate = response.last_update!;
          if (latestDateCache == null || lastUpdate.isAfter(latestDateCache)) {
            getProductFromAPI();
          } else {
            logger.d(
                "Repository Product from Cached, API : ${lastUpdate} Cache terakhir: $latestDateCache");
          }
        }
      }

      return cacheProduct;
    } else {
      return getProductFromAPI();
    }
  }

  Future<List<Product>?> getProductFromAPI() async {
    logger.d("Repository Product from API");
    ProductsResponse data = await apiService.productsGet();
    List<Product>? products = data.products;

    // insert into cache database
    if (products != null) {
      List<Map<String, dynamic>> jsonList =
          products.map((product) => product.toJson()).toList();
      String json = jsonEncode(jsonList);

      await _dbHelper.insertProductCache(json);
    }

    if (!data.error) {
      return data.products;
    } else {
      return [];
    }
  }
}
