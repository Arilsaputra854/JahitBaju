import 'package:jahit_baju/data/model/favorite.dart';

class FavoriteResponse {
  bool error;
  String? message;
  int? id;

  FavoriteResponse({required this.error, this.message, this.id});

  factory FavoriteResponse.fromJson(Map<String, dynamic> json) {
    return FavoriteResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",
      id: json['data'] != null ? json['data']['id'] as int : null,
    );
  }
}

class FavoritesResponse {
  bool error;
  String? message;
  List<Favorite>? favorites;

  FavoritesResponse({required this.error, this.message, this.favorites});

  factory FavoritesResponse.fromJson(Map<String, dynamic> json) {
    return FavoritesResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",
      favorites: json['data'] != null
          ? List<Favorite>.from(json['data'].map((x) => Favorite.fromJson(x)))
          : null,
    );
  }
}
