import 'dart:convert';
import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/model/user.dart';

class ApiService {
  final String baseUrl = "http://192.168.1.155:3000/api/";

  Future<String?> userLogin(String email, String password) async {
    final url = Uri.parse("${baseUrl}users/login");

    try {
      final response = await http.post(
        url,
        body: jsonEncode({'id': email, 'password': password}),
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
          'id': email.toLowerCase(),
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
         message= data["errors"] ?? "Unknown error occurred";
        
      }
      return message;
    } catch (e) {
      print("Error: ${e}");
      return "Network error or invalid response";
    }
  }

  Future<void> userVerifyAccount(int OtpCode) async {}



  Future<dynamic> productsGet() async {
    final url = Uri.parse("${baseUrl}products");

    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json'
      });

      var data = jsonDecode(response.body);
      dynamic message;
      if (response.statusCode == 200) {

        var productsData = data["data"] as List; 

        List<Product> products = productsData.map<Product>((json) => Product.fromJson(json)).toList();

        print(productsData);

        return products;
      } else {
         message= data["errors"] ?? "Unknown error occurred";        
         return message;
      }
      
    } catch (e) {
      print("Error: ${e}");
      return "Network error or invalid response";
    }
  }
}
