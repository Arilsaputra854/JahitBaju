import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/model/cart.dart';
import 'package:jahit_baju/model/favorite.dart';
import 'package:jahit_baju/model/order.dart';
import 'package:jahit_baju/model/packaging.dart';
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/model/shipping.dart';
import 'package:jahit_baju/model/user.dart';
import 'package:jahit_baju/service/remote/response/favorite_response.dart';
import 'package:jahit_baju/service/remote/response/login_response.dart';
import 'package:jahit_baju/service/remote/response/order_response.dart';
import 'package:jahit_baju/service/remote/response/size_guide_response.dart';
import 'package:logger/web.dart';

import 'response/term_condition_response.dart';
import 'response/user_response.dart';

class ApiService {
  final String baseUrl = "http://192.168.1.155:3000/api/";
  TokenStorage tokenStorage = TokenStorage();
  Logger logger = Logger();

  Future<LoginResponse> userLogin(String email, String password) async {
    final url = Uri.parse("${baseUrl}users/login");

    try {
      final response = await http.post(
        url,
        body: jsonEncode({'email': email, 'password': password}),
        headers: <String, String>{
          "Content-Type": "application/json",
        },
      );

      var data = jsonDecode(response.body);
      LoginResponse responseBody = LoginResponse.fromJson(data);

      return responseBody;
    } catch (e) {
      logger.e("User Login : $e");
      return LoginResponse(
          message: "Network error or invalid response", error: true);
    }
  }

  Future<dynamic> userRegister(
      String name, String email, String phoneNumber, String password) async {
    final url = Uri.parse("${baseUrl}users/register");

    try {
      final response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'email': email.toLowerCase(),
          'name': name,
          'password': password,
          'phone_number': phoneNumber,
        }),
      );

      var data = jsonDecode(response.body);
      dynamic message;

      if (response.statusCode == 200) {
        message = User.fromJson(data["data"]);
      } else {
        message = data["message"] ?? "Unknown error occurred";
      }

      return message;
    } catch (e) {
      logger.e("User Register : $e");
      return "Network error or invalid response";
    }
  }

  Future<dynamic> userGet(String token) async {
    final url = Uri.parse("${baseUrl}users/current");
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': '${token}'
    });

    try {
      var data = jsonDecode(response.body);
      dynamic message;
      if (response.statusCode == 200) {
        var userData = data["data"];

        User user = User.fromJson(userData);

        return user;
      } else {
        message = data["message"] ?? "Unknown error occurred";
      }
      return message;
    } catch (e) {
      logger.e("User Get : $e");
      return "Network error or invalid response";
    }
  }

  Future<UserResponse> userUpdate(String? name, String? email, String? password,
      String? imageUrl, String? address, String? phoneNumber) async {
    final url = Uri.parse("${baseUrl}users/current");

    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    try {
      //Create a map to hold the updated fields
      Map<String, dynamic> body = {};

      //Add fields only if they are not null or empty
      if (name != null && name.isNotEmpty) {
        body['name'] = name;
      }
      if (email != null && email.isNotEmpty) {
        body['email'] = email;
      }
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }
      if (imageUrl != null && imageUrl.isNotEmpty) {
        body['img_url'] = imageUrl;
      }
      if (address != null && address.isNotEmpty) {
        body['address'] = address;
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        body['phone_number'] = phoneNumber;
      }

      //If the body is empty, return a message
      if (body.isEmpty) {
        return UserResponse(message: "Field is empty", error: true);
      }

      //Perform the HTTP PATCH request
      final response = await http.patch(
        url,
        body: jsonEncode(body),
        headers: <String, String>{
          "Content-Type": "application/json",
          'Authorization': '${token}'
        },
      );

      var data = jsonDecode(response.body);
      UserResponse responseBody = UserResponse.fromJson(data);

      return responseBody;
    } catch (e) {
      logger.e("User Update : $e");
      return UserResponse(
          message: "Network error or invalid response", error: true);
    }
  }

  Future<LoginResponse> userEmailVerify(String otpCode) async {
    final url = Uri.parse("${baseUrl}users/current/verify-email");
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': '${token}'
        },
        body: jsonEncode(<String, String>{
          'otp': otpCode,
        }),
      );

      var data = jsonDecode(response.body);
      LoginResponse responseBody = LoginResponse.fromJson(data);

      return responseBody;
    } catch (e) {
      logger.e("User Email Verify : $e");

      return LoginResponse(
          message: "Network error or invalid response", error: true);
    }
  }

  Future<LoginResponse> userRequestOtp() async {
    final url = Uri.parse("${baseUrl}users/current/request-otp/");
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': '${token}'
        },
      );

      var data = jsonDecode(response.body);
      LoginResponse responseBody = LoginResponse.fromJson(data);

      return responseBody;
    } catch (e) {
      logger.e("User Request OTP : $e");

      return LoginResponse(
          message: "Network error or invalid response", error: true);
    }
  }


  Future<OrderResponse> buyNow(
      Order order) async {
    final url = Uri.parse("${baseUrl}order");

    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': '${token}'
        },
        body: jsonEncode(<String, dynamic>{
          'product_id': order.product!.id,
          'quantity': order.quantity,
          'total_price': order.totalPrice,
          'size': order.size,
          'order_status' : order.orderStatus,
          'shipping_id' : order.shippingId,
          'packaging_id' : order.packagingId
        }),
      );

      var data = jsonDecode(response.body);
      OrderResponse orderResponse = OrderResponse.fromJson(data);
      logger.d("Order now : ${data}");
      return OrderResponse.fromJson(data);
    } catch (e) {
      logger.e("Order now : $e");
      return OrderResponse(error: true,message: "Network error or invalid response");
    }
  }



  Future<dynamic> cartGet() async {
    final url = Uri.parse("${baseUrl}cart");

    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': '${token}'
      });

      var data = jsonDecode(response.body);
      dynamic message;
      if (response.statusCode == 200) {
        Cart cartData = Cart.fromJson(data["data"]);
        return cartData;
      } else {
        message = data["message"] ?? "Unknown error occurred";
        return message;
      }
    } catch (e) {
      logger.e("Cart Get : $e");
      return "Network error or invalid response";
    }
  }

  Future<dynamic> cartAdd(
      Product product, int quantity, String selectedSize) async {
    final url = Uri.parse("${baseUrl}cart");

    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': '${token}'
        },
        body: jsonEncode(<String, dynamic>{
          'productId': product.id,
          'quantity': quantity,
          'price': product.price,
          'size': selectedSize
        }),
      );

      var data = jsonDecode(response.body);
      dynamic message;
      if (response.statusCode == 200) {
        message = data["message"];
        return message;
      } else {
        message = data["message"] ?? "Unknown error occurred";
        return message;
      }
    } catch (e) {
      logger.e("Cart Add : $e");
      return "Network error or invalid response";
    }
  }

  Future<dynamic> itemCartDelete(CartItem item) async {
    final url = Uri.parse("${baseUrl}cart/item/${item.id}");

    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    try {
      final response = await http.delete(url, headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': '${token}'
      });

      var data = jsonDecode(response.body);
      dynamic message;
      if (response.statusCode == 200) {
        message = data["message"];
        return message;
      } else {
        message = data["message"] ?? "Unknown error occurred";
        return message;
      }
    } catch (e) {
      logger.e("Item Cart Delete : $e");
      return "Network error or invalid response";
    }
  }

  Future<dynamic> shippingGet() async {
    final url = Uri.parse("${baseUrl}shippings");

    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
      });

      var data = jsonDecode(response.body);
      dynamic message;

      if (response.statusCode == 200) {
        var productsData = data["data"] as List;

        List<Shipping> products = productsData
            .map<Shipping>((json) => Shipping.fromJson(json))
            .toList();

        return products;
      } else {
        message = data["message"] ?? "Unknown error occurred";
        return message;
      }
    } catch (e) {
      logger.e("Shipping Get : $e");
      return "error";
    }
  }

  Future<dynamic> packagingGet() async {
    final url = Uri.parse("${baseUrl}packagings");

    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
      });

      var data = jsonDecode(response.body);
      dynamic message;

      if (response.statusCode == 200) {
        var packagingData = data["data"] as List;

        List<Packaging> packaging = packagingData
            .map<Packaging>((json) => Packaging.fromJson(json))
            .toList();

        return packaging;
      } else {
        message = data["message"] ?? "Unknown error occurred";
        return message;
      }
    } catch (e) {
      logger.e("Packaging Get : $e");
      return "error";
    }
  }

  Future<dynamic> orderCreate(Order order) async {
    final url = Uri.parse("${baseUrl}order");

    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': '${token}'
        },
        body: jsonEncode(<String, dynamic>{
          'shipping_id': order.shippingId,
          'packaging_id': order.packagingId,
          'cart_id': order.cartId,
          'total_price': order.totalPrice,
          'order_status': order.orderStatus
        }),
      );

      var data = jsonDecode(response.body);
      OrderResponse orderResponse = OrderResponse.fromJson(data);

      if (response.statusCode != 201) {
        orderResponse.message = data["message"] ?? "Unknown error occurred";
        logger.e("Create Order: ${orderResponse.message}");
      }
      logger.i("Create Order: ${orderResponse.data}");
      orderResponse.data = Order.fromJson(orderResponse.data);

      return orderResponse;
    } catch (e) {
      logger.e("Create Order: ${e}");
      return OrderResponse(
          error: true, message: "Network error or invalid response");
    }
  }

  Future<OrderResponse> orderGet() async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    final url = Uri.parse("${baseUrl}order");
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': '${token}'
    });

    try {
      var data = jsonDecode(response.body);
      OrderResponse orderResponse = OrderResponse.fromJson(data);

      if (response.statusCode == 200) {
        List<Order> orders = Order.listFromJson(orderResponse.data);
        orderResponse.data = orders;
      } else {
        orderResponse.message = data["message"] ?? "Unknown error occurred";
        logger.e("Get Order: ${orderResponse.message}");
      }
      logger.i("Get Order: ${orderResponse.data}");
      return orderResponse;
    } catch (e) {
      logger.e("Get Order: ${e}");
      return OrderResponse(
          error: true, message: "Network error or invalid response");
    }
  }

  Future<OrderResponse> orderDelete(var orderId) async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    final url = Uri.parse("${baseUrl}order/${orderId}");
    final response = await http.delete(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': '${token}'
    });

    try {
      var data = jsonDecode(response.body);
      OrderResponse orderResponse = OrderResponse.fromJson(data);

      logger.i("Delete Order: ${orderResponse.message}");
      return orderResponse;
    } catch (e) {
      logger.e("Delete Order: ${e}");
      return OrderResponse(
          error: true, message: "Network error or invalid response");
    }
  }

  productsGetById(String productId) async {
    final url = Uri.parse("${baseUrl}products/$productId");
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': '${token}'
      });

      var data = jsonDecode(response.body);
      dynamic message;
      if (response.statusCode == 200) {
        var productData = data["data"];

        Product product = Product.fromJson(productData);

        return product;
      } else {
        message = data["message"] ?? "Unknown error occurred";
        return message;
      }
    } catch (e) {
      print("Error: ${e}");
      return "Network error or invalid response";
    }
  }

  Future<dynamic> productsGet() async {
    final url = Uri.parse("${baseUrl}products");

    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
      });

      var data = jsonDecode(response.body);
      dynamic message;
      if (response.statusCode == 200) {
        var productsData = data["data"] as List;

        List<Product> products = productsData
            .map<Product>((json) => Product.fromJson(json))
            .toList();
        return products;
      } else {
        message = data["message"] ?? "Unknown error occurred";
        return message;
      }
    } catch (e) {
      print("Error: ${e}");
      return "error";
    }
  }

  Future<dynamic> favoriteGet() async {
    final url = Uri.parse("${baseUrl}favorite");
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': '${token}'
      });

      var data = jsonDecode(response.body);
      dynamic message;
      if (response.statusCode == 200) {
        var favoriteData = data["data"] as List;

        List<Favorite> favorites = favoriteData
            .map<Favorite>((json) => Favorite.fromJson(json))
            .toList();

        return favorites;
      } else {
        message = data["message"] ?? "Unknown error occurred";
        return message;
      }
    } catch (e) {
      print("Error: ${e}");
      return "error";
    }
  }

  Future<FavoriteResponse> favoriteDelete(int id) async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    final url = Uri.parse("${baseUrl}favorite");
    final response = await http.delete(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': '${token}'
        },
        body: jsonEncode(<String, dynamic>{"id": id}));

    try {
      var data = jsonDecode(response.body);

      FavoriteResponse favoriteResponse = FavoriteResponse.fromJson(data);

      return favoriteResponse;
    } catch (e) {
      print("Error: ${e}");
      return FavoriteResponse(
          error: true, message: "Network error or invalid response");
    }
  }

  Future<FavoriteResponse> favoriteAdd(Favorite favorite) async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    final url = Uri.parse("${baseUrl}favorite");
    final response = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': '${token}'
        },
        body: jsonEncode(<String, dynamic>{"product_id": favorite.productId}));

    try {
      var data = jsonDecode(response.body);

      FavoriteResponse favoriteResponse = FavoriteResponse.fromJson(data);

      return favoriteResponse;
    } catch (e) {
      print("Error: ${e}");
      return FavoriteResponse(
          error: true, message: "Network error or invalid response");
    }
  }

  Future<dynamic> termCondition() async {
    final url = Uri.parse("${baseUrl}term-condition");
    final response = await http.get(url,
        headers: <String, String>{'Content-Type': 'application/json'});

    try {
      var data = jsonDecode(response.body);
      print(data);
      TermConditionResponse termConditionResponse =
          TermConditionResponse.fromJson(data);

      return termConditionResponse;
    } catch (e) {
      logger.e("Term Condition : $e");
      return "Network error or invalid response";
    }
  }

  Future<dynamic> sizeGuide() async {
    final url = Uri.parse("${baseUrl}size-guide");
    final response = await http.get(url,
        headers: <String, String>{'Content-Type': 'application/json'});

    try {
      var data = jsonDecode(response.body);
      SizeGuideResponse sizeGuideResponse = SizeGuideResponse.fromJson(data);

      return sizeGuideResponse;
    } catch (e) {
      logger.e("Size Guide : $e");
      return "Network error or invalid response";
    }
  }
}
