import 'dart:convert';
import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:jahit_baju/model/cart.dart';
import 'package:jahit_baju/model/order.dart';
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/model/user.dart';

class ApiService {
  final String baseUrl = "http://192.168.1.155:3000/api/";

  Future<String?> userLogin(String email, String password) async {
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
      String? message;

      if (response.statusCode == 200) {
        message = data["data"]["token"];
      } else {
        message = data["errors"];
      }

      return message;
    } catch (e) {
      print("Error: $e");
      return "Network error or invalid response";
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
        message = data["errors"] ?? "Unknown error occurred";
      }

      return message;
    } catch (e) {
      print("Error: $e");
      return "Network error or invalid response";
    }
  }

  Future<dynamic> userGet(String token) async {
    final url = Uri.parse("${baseUrl}users/current");

    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': '${token}'
      });

      var data = jsonDecode(response.body);
      dynamic message;
      if (response.statusCode == 200) {
        var userData = data["data"];

        User user = User.fromJson(userData);

        return user;
      } else {
        message = data["errors"] ?? "Unknown error occurred";
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

      print(response.body);

      var data = jsonDecode(response.body);
      String? message;

      // Check the response status
      if (response.statusCode == 200) {
        message = "Update successful";
      } else {
        message = data["errors"] ?? "Unknown error occurred";
      }

      return message;
    } catch (e) {
      print("Error: $e");
      return "Network error or invalid response";
    }
  }

  Future<void> userVerifyAccount(int OtpCode) async {}

  Future<dynamic> productsGet() async {
    final url = Uri.parse("${baseUrl}products");

    try {
      final response = await http.get(url,
          headers: <String, String>{'Content-Type': 'application/json',
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
        message = data["errors"] ?? "Unknown error occurred";
        return message;
      }
    } catch (e) {
      print("Error: ${e}");
      return "Network error or invalid response";
    }
  }


   Future<dynamic> cartGet(var token) async {
    final url = Uri.parse("${baseUrl}cart");

    try {
      final response = await http.get(url,
          headers: <String, String>{'Content-Type': 'application/json','Authorization': '${token}'});

      var data = jsonDecode(response.body);
      dynamic message;
      if (response.statusCode == 200) {
        var ordersData = data["data"] as List;

        List<Cart> orders = ordersData
            .map<Cart>((json) => Cart.fromJson(json))
            .toList();

        return orders;
      } else {
        message = data["errors"] ?? "Unknown error occurred";
        return message;
      }
    } catch (e) {
      print("Error: ${e}");
      return "Network error or invalid response";
    }
  }

  productsGetById(String token, String productId) async{
    final url = Uri.parse("${baseUrl}products/$productId");

    try {
      final response = await http.get(url,
          headers: <String, String>{'Content-Type': 'application/json', 'Authorization': '${token}'
          });

      var data = jsonDecode(response.body);
      dynamic message;
      if (response.statusCode == 200) {
        var productData = data["data"];

        Product product = Product.fromJson(productData);


        return product;
      } else {
        message = data["errors"] ?? "Unknown error occurred";
        return message;
      }
    } catch (e) {
      print("Error: ${e}");
      return "Network error or invalid response";
    }
  }
}
