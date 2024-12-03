import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/model/cart.dart';
import 'package:jahit_baju/model/order.dart';
import 'package:jahit_baju/model/packaging.dart';
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/model/shipping.dart';
import 'package:jahit_baju/model/user.dart';
import 'package:jahit_baju/service/remote/response/login_response.dart';

class ApiService {
  final String baseUrl = "http://192.168.1.155:3000/api/";
  TokenStorage tokenStorage = TokenStorage();

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
      print("Error: $e");
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
      print("Error: $e");
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
      print("Error: ${e}");
      return "Network error or invalid response";
    }
  }

  Future<String?> userUpdate(String token, String? email, String? password,
      String? imageUrl, String? address, String? phoneNumber) async {
    final url = Uri.parse("${baseUrl}users/current");

    try {
      // Create a map to hold the updated fields
      Map<String, dynamic> body = {};

      // Add fields only if they are not null or empty
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

      // If the body is empty, return a message
      if (body.isEmpty) {
        return "No fields to update.";
      }

      // Perform the HTTP PATCH request
      final response = await http.patch(
        url,
        body: jsonEncode(body),
        headers: <String, String>{
          "Content-Type": "application/json",
          'Authorization': '${token}'
        },
      );

      var data = jsonDecode(response.body);
      String? message;

      // Check the response status
      if (response.statusCode == 200) {
        message = "Update successful";
      } else {
        message = data["message"] ?? "Unknown error occurred";
      }

      return message;
    } catch (e) {
      print("Error: $e");
      return "Network error or invalid response";
    }
  }

  Future<void> userVerifyAccount(int OtpCode) async {}

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
      print("Error: ${e}");
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
      print(data);
      dynamic message;
      if (response.statusCode == 200) {
        message = data["message"];
        return message;
      } else {
        message = data["message"] ?? "Unknown error occurred";
        return message;
      }
    } catch (e) {
      print("Error: ${e}");
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
      print("Error: ${e}");
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
      print("Error: ${e}");
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
      print("Error: ${e}");
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
          'buyer_id': order.buyerId,
          'shipping_id': order.shippingId,
          'packaging_id': order.packagingId,
          'cart_id': order.cartId,
          'total_price': order.totalPrice,
          'order_status': order.orderStatus
        }),
      );

      var data = jsonDecode(response.body);
      dynamic message;
      if (response.statusCode == 201) {
        var order = data["data"];

        return Order.fromJson(order);
      } else {
        message = data["message"] ?? "Unknown error occurred";
        return message;
      }
    } catch (e) {
      print("Error: ${e}");
      return "Network error or invalid response";
    }
  }

  Future<dynamic> orderGet() async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    final url = Uri.parse("${baseUrl}order");
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': '${token}'
    });

    try {
      var data = jsonDecode(response.body);
      dynamic message;

      if (response.statusCode == 200) {
        var ordersData = data["data"];

        List<Order> orders = Order.listFromJson(ordersData);

        return orders;
      } else {
        message = data["message"] ?? "Unknown error occurred";
      }
      return message;
    } catch (e) {
      print("Error: ${e}");
      return "Network error or invalid response";
    }
  }

  Future<dynamic> orderDelete(var orderId) async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    final url = Uri.parse("${baseUrl}order/${orderId}");
    final response = await http.delete(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': '${token}'
    });

    try {
      var data = jsonDecode(response.body);

      var message = data["message"];

      return message;
    } catch (e) {
      print("Error: ${e}");
      return "Network error or invalid response";
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
}
