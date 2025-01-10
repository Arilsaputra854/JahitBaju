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
import 'package:jahit_baju/service/remote/response/otp_response.dart';
import 'package:jahit_baju/service/remote/response/size_guide_response.dart';
import 'package:jahit_baju/service/remote/response/survei_response.dart';
import 'package:logger/web.dart';

import 'response/term_condition_response.dart';
import 'response/user_response.dart';

class ApiService {
  final String baseUrl =
      "https://jahit-baju-backend-936228436122.asia-east1.run.app/api/";
  // final String baseUrl =
  //     "http://192.168.1.13:3000/api/";
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
      logger.d("User Login : $data");
      LoginResponse responseBody = LoginResponse.fromJson(data);

      return responseBody;
    } catch (e) {
      logger.e("User Login : $e");
      return LoginResponse(message: "Network error : $e", error: true);
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

      logger.d("User Register : $data");

      if (response.statusCode == 200) {
        message = User.fromJson(data["data"]);
      } else {
        message = data["message"] ?? "Unknown error occurred";
      }

      return message;
    } catch (e) {
      logger.e("User Register : $e");
      return "Network error : $e";
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

      logger.d("User Get : $data");

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
      return "Network error : $e";
    }
  }

  Future<UserResponse> userUpdate(String? name, String? email, String? password,
      String? imageUrl, String? address, String? phoneNumber, {String? resetToken}) async {
    final url = Uri.parse("${baseUrl}users/current");

    String? token = resetToken ?? await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    
    logger.d("Token: ${token}");

    try {
      
      Map<String, dynamic> body = {};

      
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

      
      final response = await http.patch(
        url,
        body: jsonEncode(body),
        headers: <String, String>{
          "Content-Type": "application/json",
          'Authorization': '${token}'
        },
      );


      var data = jsonDecode(response.body);
      
      logger.d("User Update : $data");

      UserResponse responseBody = UserResponse.fromJson(data);

      return responseBody;
    } catch (e) {
      logger.e("User Update : $e");
      return UserResponse(message: "Network error : $e", error: true);
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

      logger.d("User Email Verify : $data");

      LoginResponse responseBody = LoginResponse.fromJson(data);

      return responseBody;
    } catch (e) {
      logger.e("User Email Verify : $e");

      return LoginResponse(message: "Network error : $e", error: true);
    }
  }

  Future<OtpResponse> userRequestOtp() async {
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
      logger.d("User Request OTP : ${data}");

      OtpResponse responseBody = OtpResponse.fromJson(data);
      return responseBody;
    } catch (e) {
      logger.e("User Request OTP : $e");

      return OtpResponse(message: "Network error : $e", error: true);
    }
  }


  Future<OtpResponse> userResetEmailVerify(String email, String otp) async {
    final url = Uri.parse("${baseUrl}users/verify-reset-otp");    
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',          
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'otp': otp,
        }),
      );

      var data = jsonDecode(response.body);

      logger.d("User Reset Email Verify : $data");

      OtpResponse responseBody = OtpResponse.fromJson(data);

      return responseBody;
    } catch (e) {
      logger.e("User Reset Email Verify : $e");

      return OtpResponse(message: "Network error : $e", error: true);
    }
  }

  Future<LoginResponse> userResetRequestOtp(String email) async {
    final url = Uri.parse("${baseUrl}users/request-reset-otp");
    
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String,String>{
          'email': email,
        }
      ));

      var data = jsonDecode(response.body);
      logger.d("User Reset Request OTP : ${data}");

      LoginResponse responseBody = LoginResponse.fromJson(data);
      return responseBody;
    } catch (e) {
      logger.e("User Reset Request OTP : $e");

      return LoginResponse(message: "Network error : $e", error: true);
    }
  }


  Future<OrderResponse> buyNow(Order order) async {
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
          'order_status': order.orderStatus,
          'shipping_id': order.shippingId,
          'packaging_id': order.packagingId
        }),
      );

      var data = jsonDecode(response.body);
      logger.d("Order now : ${data}");
      OrderResponse orderResponse = OrderResponse.fromJson(data);
      logger.d("Order now : ${data}");
      return OrderResponse.fromJson(data);
    } catch (e) {
      logger.e("Order now : $e");
      return OrderResponse(error: true, message: "Network error : $e");
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
      logger.d("Cart Get : ${data}");

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
      return "Network error : $e";
    }
  }

  Future<dynamic> cartAdd(
    Product product, int quantity, String selectedSize, String? customDesignSvg) async {
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
          'size': selectedSize,
          'custom_design' : customDesignSvg
        }),
      );

      var data = jsonDecode(response.body);
      logger.d("Cart Add : ${data}");

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
      return "Network error : $e";
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
      logger.d("Item Cart Delete : ${data}");

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
      return "Network error : $e";
    }
  }

  Future<dynamic> shippingGet() async {
    final url = Uri.parse("${baseUrl}shippings");

    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
      });

      var data = jsonDecode(response.body);
      logger.d("Shipping Get : ${data}");

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
      logger.d("Packaging Get : ${data}");
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
      logger.d("Create Order : ${data}");

      OrderResponse orderResponse = OrderResponse.fromJson(data);

      if (response.statusCode != 201) {
        orderResponse.message = data["message"] ?? "Unknown error occurred";
        logger.e("Create Order: ${orderResponse.message}");
      }

      orderResponse.data = Order.fromJson(orderResponse.data);

      return orderResponse;
    } catch (e) {
      logger.e("Create Order: ${e}");
      return OrderResponse(error: true, message: "Network error : $e");
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
      
      logger.d("Get Order : ${data}");

      OrderResponse orderResponse = OrderResponse.fromJson(data);

      if (response.statusCode == 200) {
        List<Order> orders = Order.listFromJson(orderResponse.data);
        orderResponse.data = orders;
      } else {
        orderResponse.message = data["message"] ?? "Unknown error occurred";
        logger.e("Get Order: ${orderResponse.message}");
      }
      
      return orderResponse;
    } catch (e) {
      logger.e("Get Order: ${e}");
      return OrderResponse(error: true, message: "Network error : $e");
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

      logger.d("Delete Order : ${data}");

      OrderResponse orderResponse = OrderResponse.fromJson(data);
      
      return orderResponse;
    } catch (e) {
      logger.e("Delete Order: ${e}");
      return OrderResponse(error: true, message: "Network error : $e");
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

      logger.d("Get Product by ID : ${data}");

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
      logger.e("Get Product by ID : ${e}");
      return "Network error : $e";
    }
  }

  Future<dynamic> productsGet() async {
    final url = Uri.parse("${baseUrl}products");
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json',
    });

    var data = jsonDecode(response.body);

    logger.d("Get Product : ${data}");

    dynamic message;
    try {
      if (response.statusCode == 200) {
        var productsData = data["data"] as List;

        List<Product> products = productsData.map<Product>((json) {
          return Product.fromJson(json);
        }).toList();

        return products;
      } else {
        message = data["message"] ?? "Unknown error occurred";
        return message;
      }
    } catch (e) {
      logger.e("Get Product : ${e}");
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


      logger.d("Get Favorite : ${data}");

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
      
      logger.e("Get Favorite : ${e}");
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

      logger.d("Delete Favorite : ${data}");

      FavoriteResponse favoriteResponse = FavoriteResponse.fromJson(data);

      return favoriteResponse;
    } catch (e) {
      logger.e("Delete Favorite : $e");
      return FavoriteResponse(error: true, message: "Network error : $e");
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

      logger.d("Add Favorite : ${data}");

      FavoriteResponse favoriteResponse = FavoriteResponse.fromJson(data);

      return favoriteResponse;
    } catch (e) {
      logger.e("Add Favorite : $e");
      return FavoriteResponse(error: true, message: "Network error : $e");
    }
  }

  Future<dynamic> termCondition() async {
    final url = Uri.parse("${baseUrl}term-condition");
    final response = await http.get(url,
        headers: <String, String>{'Content-Type': 'application/json'});

    try {
      var data = jsonDecode(response.body);
      
      logger.d("Term Condition : ${data}");
      TermConditionResponse termConditionResponse =
          TermConditionResponse.fromJson(data);

      return termConditionResponse;
    } catch (e) {
      logger.e("Term Condition : $e");
      return "Network error : $e";
    }
  }

  Future<dynamic> sizeGuide() async {
    final url = Uri.parse("${baseUrl}size-guide");
    final response = await http.get(url,
        headers: <String, String>{'Content-Type': 'application/json'});

    try {
      var data = jsonDecode(response.body);
      logger.d("Size Guide : ${data}");
      SizeGuideResponse sizeGuideResponse = SizeGuideResponse.fromJson(data);

      return sizeGuideResponse;
    } catch (e) {
      logger.e("Size Guide : $e");
      return "Network error : $e";
    }
  }


  Future<SurveiResponse> sendSurveiData(String question1, String question2, String question3) async {
    final url = Uri.parse("${baseUrl}survei-custom");
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': '${token}'
        },
        body: jsonEncode(<String,String>{
          'question_1': question1,
          'question_2': question2,
          'question_3': question3,
        }
      ));

      var data = jsonDecode(response.body);
      logger.d("Send User Data : ${data}");

      SurveiResponse responseBody = SurveiResponse.fromJson(data);
      return responseBody;
    } catch (e) {
      logger.e("Send User Data : $e");

      return SurveiResponse(message: "Network error : $e", error: true);
    }
  }


}
