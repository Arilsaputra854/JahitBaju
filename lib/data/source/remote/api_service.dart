import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jahit_baju/data/model/look.dart';
import 'package:jahit_baju/data/model/user.dart';
import 'package:jahit_baju/data/source/remote/response/app_banner_response.dart';
import 'package:jahit_baju/data/source/remote/response/care_guide_response.dart';
import 'package:jahit_baju/data/source/remote/response/city_response.dart';
import 'package:jahit_baju/data/source/remote/response/custom_design_response.dart';
import 'package:jahit_baju/data/source/remote/response/customization_feature_response.dart';
import 'package:jahit_baju/data/source/remote/response/designer_response.dart';
import 'package:jahit_baju/data/source/remote/response/feature_order_reaspones.dart';
import 'package:jahit_baju/data/source/remote/response/feature_response.dart';
import 'package:jahit_baju/data/source/remote/response/look_access_response.dart';
import 'package:jahit_baju/data/source/remote/response/look_order_response.dart';
import 'package:jahit_baju/data/source/remote/response/look_response.dart';
import 'package:jahit_baju/data/source/remote/response/packaging_response.dart';
import 'package:jahit_baju/data/source/remote/response/product_note_response.dart';
import 'package:jahit_baju/data/source/remote/response/product_term_response.dart';
import 'package:jahit_baju/data/source/remote/response/province_response.dart';
import 'package:jahit_baju/data/source/remote/response/register_response.dart';
import 'package:jahit_baju/data/source/remote/response/shipping_response.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/data/model/cart.dart';
import 'package:jahit_baju/data/model/favorite.dart';
import 'package:jahit_baju/data/model/order.dart';
import 'package:jahit_baju/data/model/packaging.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/source/remote/response/favorite_response.dart';
import 'package:jahit_baju/data/source/remote/response/login_response.dart';
import 'package:jahit_baju/data/source/remote/response/order_response.dart';
import 'package:jahit_baju/data/source/remote/response/otp_response.dart';
import 'package:jahit_baju/data/source/remote/response/product_response.dart';
import 'package:jahit_baju/data/source/remote/response/size_guide_response.dart';
import 'package:logger/web.dart';
import 'package:http_parser/http_parser.dart';

import '../../../util/util.dart';
import 'response/cart_response.dart';
import 'response/term_condition_response.dart';
import 'response/user_response.dart';

class ApiService {
  final String baseUrl = "https://v1.jahitbajuofficial.com/api/";
  //final String baseUrl = "https://bonefish-supreme-sculpin.ngrok-free.app/api/";

  TokenStorage tokenStorage = TokenStorage();
  Logger logger = Logger();
  final BuildContext context;

  static const String SOMETHING_WAS_WRONG =
      "Maaf, Terjadi kesalahan, silakan coba lagi nanti.";
  static const String SOMETHING_WAS_WRONG_SERVER =
      "Maaf, terjadi kesalahan pada server kami, Silakan coba lagi nanti.";
  static const String NO_INTERNET_CONNECTION = "Tidak ada koneksi internet.";
  static const String UNAUTHORIZED = "Tidak ada koneksi internet.";

  ApiService(this.context);

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
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("User Register : Tidak ada koneksi internet");

      return LoginResponse(error: true);
    } catch (e) {
      logger.e("User Login : $e");
      return LoginResponse(message: "Network error : $e", error: true);
    }
  }

  Future<RegisterResponse> userRegister(
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

      logger.d("User Register : $data");

      return RegisterResponse.fromJson(data);
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("User Register : Tidak ada koneksi internet");

      return RegisterResponse(error: true, message: NO_INTERNET_CONNECTION);
    } catch (e) {
      logger.e("User Register : $e");
      return RegisterResponse(error: true, message: SOMETHING_WAS_WRONG);
    }
  }

  Future<UserResponse> userGet() async {
    final url = Uri.parse("${baseUrl}users/current");

    String? token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token}'
    });

    try {
      var data = jsonDecode(response.body);

      if (response.statusCode == 401) {
        logger.e("User Get : $data");
        showDialogSession(context);
        return UserResponse(message: UNAUTHORIZED, error: true);
      }
      logger.d("User Get : $data");

      return UserResponse.fromJson(data);
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("User Get : Tidak ada koneksi internet");
      return UserResponse(message: "Tidak ada internet", error: true);
    } catch (e) {
      logger.e("User Get : $e");
      return UserResponse(message: "Network error : $e", error: true);
    }
  }

  Future<UserResponse> userUpdate(String? name, String? email, String? password,
      String? imageUrl, Address? address, String? phoneNumber,
      {String? resetToken}) async {
    final url = Uri.parse("${baseUrl}users/current");

    String? token =
        resetToken ?? await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    logger.d("Token: Bearer ${token}");

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
      if (address != null) {
        body['address'] = address.toJson();
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        body['phone_number'] = phoneNumber;
      }

      //If the body is empty, return a message
      if (body.isEmpty) {
        return UserResponse(message: "Field is empty", error: true);
      }


      logger.d("body address :${body}");

      final response = await http.patch(
        url,
        body: jsonEncode(body),
        headers: <String, String>{
          "Content-Type": "application/json",
          'Authorization': 'Bearer ${token}'
        },
      );

      var data = jsonDecode(response.body);

      logger.d("User Update : $data");

      UserResponse responseBody = UserResponse.fromJson(data);

      return responseBody;
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("User Update: Tidak ada koneksi internet");
      return UserResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("User Update : $e");
      return UserResponse(message: "Network error : $e", error: true);
    }
  }

  Future<OtpResponse> userEmailVerify(String otpCode) async {
    final url = Uri.parse("${baseUrl}users/current/verify-email");
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token}'
        },
        body: jsonEncode(<String, String>{
          'otp': otpCode,
        }),
      );

      var data = jsonDecode(response.body);

      logger.d("User Email Verify : $data");

      return OtpResponse.fromJson(data);

    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("User Email Verify : Tidak ada koneksi internet");
      return OtpResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("User Email Verify : $e");

      return OtpResponse(message: "Network error : $e", error: true);
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
          'Authorization': 'Bearer ${token}'
        },
      );

      var data = jsonDecode(response.body);
      logger.d("User Request OTP : ${data}");

      OtpResponse responseBody = OtpResponse.fromJson(data);
      return responseBody;
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("User Request OTP : Tidak ada koneksi internet");
      return OtpResponse(message: NO_INTERNET_CONNECTION, error: true);
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
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("User Reset Email Verify : Tidak ada koneksi internet");
      return OtpResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("User Reset Email Verify : $e");

      return OtpResponse(message: "Network error : $e", error: true);
    }
  }

  Future<OtpResponse> userResetRequestOtp(String email) async {
    final url = Uri.parse("${baseUrl}users/request-reset-otp");

    try {
      final response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, String>{
            'email': email,
          }));

      var data = jsonDecode(response.body);
      logger.d("User Reset Request OTP : ${data}");

      return OtpResponse.fromJson(data);
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("User Reset Request OTP : Tidak ada koneksi internet");
      return OtpResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("User Reset Request OTP : $e");

      return OtpResponse(message: "Network error : $e", error: true);
    }
  }

  Future<OrderResponse> buyNow(Order order, {String? filename}) async {
    final url = Uri.parse("${baseUrl}order");

    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    try {
      final response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${token}'
          },
          body: order.look != null
              ? jsonEncode(<String, dynamic>{
                  'packaging_price': order.packagingPrice,
                  'shipping_price': order.shippingPrice,
                  'custom_price': order.customPrice,
                  'rtw_price': order.rtwPrice,
                  'discount': order.discount,
                  'look_id': order.look?.id,
                  'custom_design': filename,
                  'quantity': order.quantity,
                  'total_price': order.totalPrice,
                  'size': order.size,
                  'order_status': order.orderStatus,
                  'shipping_id': order.shippingId,
                  'packaging_id': order.packagingId,
                  'description':
                      order.description!.isNotEmpty ? order.description : null
                })
              : jsonEncode(<String, dynamic>{
                  'packaging_price': order.packagingPrice,
                  'shipping_price': order.shippingPrice,
                  'custom_price': order.customPrice,
                  'rtw_price': order.rtwPrice,
                  'discount': order.discount,
                  'product_id': order.product?.id,
                  'quantity': order.quantity,
                  'total_price': order.totalPrice,
                  'size': order.size,
                  'order_status': order.orderStatus,
                  'shipping_id': order.shippingId,
                  'packaging_id': order.packagingId,
                  'description':
                      order.description!.isNotEmpty ? order.description : null
                }));

      var data = jsonDecode(response.body);
      OrderResponse orderResponse = OrderResponse.fromJson(data);
      logger.d("Order now : ${data}");
      return orderResponse;
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Order New : Tidak ada koneksi internet");
      return OrderResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("Order now : $e");
      return OrderResponse(error: true, message: "Network error : $e");
    }
  }

  Future<CartResponse> cartGet() async {
    final url = Uri.parse("${baseUrl}cart");

    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token}'
    });

    CartResponse cartResponse;

    try {
      var data = jsonDecode(response.body);
      logger.d("Cart Get : ${data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        cartResponse = CartResponse.fromJson(data);
      } else if (response.statusCode >= 500) {
        cartResponse =
            CartResponse(error: true, message: SOMETHING_WAS_WRONG_SERVER);
      } else if (response.statusCode == 401) {
        showDialogSession(context);
        cartResponse = CartResponse(error: true, message: UNAUTHORIZED);
      } else {
        cartResponse = CartResponse(error: true, message: SOMETHING_WAS_WRONG);
      }
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Cart Get : Tidak ada koneksi internet");
      cartResponse = CartResponse(error: true, message: NO_INTERNET_CONNECTION);
    } catch (e) {
      logger.e("Cart Get : $e");
      cartResponse = CartResponse(error: true, message: SOMETHING_WAS_WRONG);
    }

    return cartResponse;
  }

  Future<CartResponse?> cartAdd(

      {required int quantity, required String selectedSize, String? customDesignSvg, Product? product, Look? look, required int weight}) async {
    final url = Uri.parse("${baseUrl}cart");

    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token}'
        },
        body: look != null
            ? jsonEncode(<String, dynamic>{
                'look_id': look.id,
                'quantity': quantity,
                'price': look.price,
                'size': selectedSize,
                'weight' : weight,
                'custom_design': customDesignSvg
              })
            : jsonEncode(<String, dynamic>{
                'product_id': product!.id,
                'quantity': quantity,
                'weight' : weight,
                'price': product.price,
                'size': selectedSize,
              }),
      );

      var data = jsonDecode(response.body);
      logger.d("Cart Add : ${data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CartResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        showDialogSession(context);
        return CartResponse(error: true, message: UNAUTHORIZED);
      } else {
        return
            CartResponse(error: true, message: SOMETHING_WAS_WRONG_SERVER);
      }
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Cart Add : Tidak ada koneksi internet");
      return CartResponse(error: true, message: NO_INTERNET_CONNECTION);
    } catch (e) {
      logger.e("Cart Add : $e");
    }
  }

  Future<dynamic> itemCartDelete(CartItem item) async {
    final url = Uri.parse("${baseUrl}cart/item/${item.id}");

    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    try {
      final response = await http.delete(url, headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token}'
      });

      var data = jsonDecode(response.body);
      logger.d("Item Cart Delete : ${data}");

      dynamic message;
      if (response.statusCode == 200 || response.statusCode == 201) {
        message = data["message"];
        return message;
      } else {
        message = data["message"] ?? "Unknown error occurred";
        return message;
      }
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Item Cart Delete : Tidak ada koneksi internet");
      return NO_INTERNET_CONNECTION;
    } catch (e) {
      logger.e("Item Cart Delete : $e");
      return "Network error : $e";
    }
  }

  Future<ShippingsResponse> getAllShipping(int totalWeight) async {
    final url = Uri.parse("${baseUrl}shippings");
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    try {
      final response = await http.post(url, headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token}'
      },body: jsonEncode(<String, dynamic>{
                'total_weight': totalWeight,
              }));

      var data = jsonDecode(response.body);
      logger.d("Shipping Get : ${data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ShippingsResponse.fromJson(data);
      } else if (response.statusCode >= 500) {
        return ShippingsResponse(
            error: true, message: SOMETHING_WAS_WRONG_SERVER);
      } else if (response.statusCode == 401) {
        showDialogSession(context);
        return ShippingsResponse(error: true, message: UNAUTHORIZED);
      } else {
        return ShippingsResponse(error: true, message: SOMETHING_WAS_WRONG);
      }
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Shipping Get : Tidak ada koneksi internet");
        return ShippingsResponse(error: true, message: NO_INTERNET_CONNECTION);
    } catch (e) {
      logger.e("Shipping Get : $e");
        return ShippingsResponse(error: true, message: SOMETHING_WAS_WRONG);
    }
  }

  Future<ShippingResponse> getShipping(String shippingId) async {
    final url = Uri.parse("${baseUrl}shipping?id=$shippingId");
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token}'
      });

      var data = jsonDecode(response.body);
      logger.d("Shipping Get : ${data}");

      ShippingResponse shippingResponse = ShippingResponse.fromJson(data);

      return shippingResponse;
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Shipping Get: Tidak ada koneksi internet");
      return ShippingResponse(
          error: true, message: "Tidak ada koneksi internet.");
    } catch (e) {
      logger.e("Shipping Get : $e");
      return ShippingResponse(error: true, message: "Terjadi kesalahan.");
    }
  }

  Future<dynamic> getAllPackaging() async {
    final url = Uri.parse("${baseUrl}packaging");

    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
      });

      var data = jsonDecode(response.body);
      logger.d("Packaging Get : ${data}");
      dynamic message;

      if (response.statusCode == 200 || response.statusCode == 201) {
        var packagingData = data["data"] as List;

        List<Packaging> packaging = packagingData
            .map<Packaging>((json) => Packaging.fromJson(json))
            .toList();

        return packaging;
      } else {
        message = data["message"] ?? "Unknown error occurred";
        return message;
      }
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Packaging Get : Tidak ada koneksi internet");
      return NO_INTERNET_CONNECTION;
    } catch (e) {
      logger.e("Packaging Get : $e");
      return "error";
    }
  }

  Future<PackagingResponse> getPackaging(String packagingId) async {
    final url = Uri.parse("${baseUrl}packaging?id=$packagingId");

    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
      });

      var data = jsonDecode(response.body);
      logger.d("Get Packaging : ${data}");

      return PackagingResponse.fromJson(data);
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Get Packaging : Tidak ada koneksi internet");
      return PackagingResponse(
          error: true, message: "Tidak ada koneksi internet.");
    } catch (e) {
      logger.e("Get Packaging : $e");
      return PackagingResponse(
          error: true, message: "Terjadi kesalahan, Coba lagi nanti.");
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
          'Authorization': 'Bearer ${token}'
        },
        body: jsonEncode(<String, dynamic>{
          'shipping_id': order.shippingId,
          'packaging_id': order.packagingId,
          'packaging_price': order.packagingPrice,
          'shipping_price': order.shippingPrice,
          'discount': order.discount,
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
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Create Order : Tidak ada koneksi internet");
      return NO_INTERNET_CONNECTION;
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
      'Authorization': 'Bearer ${token}'
    });

    OrderResponse orderResponse;
    try {
      var data = jsonDecode(response.body);

      logger.d("Get Order : ${data}");

      orderResponse = OrderResponse.fromJson(data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<Order> orders = Order.listFromJson(orderResponse.data);
        orderResponse.data = orders;
      } else if (response.statusCode >= 500) {
        orderResponse =
            OrderResponse(error: true, message: SOMETHING_WAS_WRONG_SERVER);
      } else if (response.statusCode == 401) {
        showDialogSession(context);
        orderResponse = OrderResponse(error: true, message: UNAUTHORIZED);
      } else {
        orderResponse =
            OrderResponse(error: true, message: SOMETHING_WAS_WRONG);
      }
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Get Order : Tidak ada koneksi internet");
      orderResponse =
          OrderResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("Get Order: ${e}");
      orderResponse = OrderResponse(error: true, message: "Network error : $e");
    }

    return orderResponse;
  }

  Future<OrderResponse> orderDelete(var orderId) async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    final url = Uri.parse("${baseUrl}order/${orderId}");
    final response = await http.delete(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token}'
    });

    try {
      var data = jsonDecode(response.body);

      logger.d("Delete Order : ${data}");

      OrderResponse orderResponse = OrderResponse.fromJson(data);

      return orderResponse;
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Delete Order : Tidak ada koneksi internet");
      return OrderResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("Delete Order: ${e}");
      return OrderResponse(error: true, message: "Network error : $e");
    }
  }

  Future<ProductResponse> productsGetById(String productId) async {
    final url = Uri.parse("${baseUrl}products?id=$productId");
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token}'
      });

      var data = jsonDecode(response.body);

      logger.d("Get Product by ID : ${data}");

      ProductResponse productResponse = ProductResponse.fromJson(data);
      return productResponse;
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Get Product by ID : Tidak ada koneksi internet");

      return ProductResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("Get Product by ID : ${e}");
      return ProductResponse(
          error: true, message: "Network error : $e", product: null);
    }
  }

  Future<LookResponse> getLookGetById(String lookId) async {
    final url = Uri.parse("${baseUrl}designer/look?id=$lookId");
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token}'
      }).timeout(Duration(seconds: 10));

      var data = jsonDecode(response.body);

      logger.d("Get Look by ID : ${data}");

      return LookResponse.fromJson(data);
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Get Look by ID : Tidak ada koneksi internet");

      return LookResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("Get Look by ID : ${e}");
      return LookResponse(
        error: true,
        message: SOMETHING_WAS_WRONG,
      );
    }
  }

  Future<ProductLatestResponse> productsGetByLastUpdate() async {
    final url = Uri.parse("${baseUrl}products/latest");
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json',
    });

    var data = jsonDecode(response.body);

    logger.d("Get Product by Last Update : ${data}");

    try {
      ProductLatestResponse productLatestResponse;
      if (response.statusCode == 200 || response.statusCode == 201) {
        productLatestResponse = ProductLatestResponse.fromJson(data);
      } else {
        logger.e("Product by Last Update : ${data["message"]}");
        productLatestResponse =
            ProductLatestResponse(error: true, message: data["message"]);
      }
      return productLatestResponse;
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Get Product by Last Update : Tidak ada koneksi internet");
      return ProductLatestResponse(
          message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("Get Product by Last Update : ${e}");
      return ProductLatestResponse(error: true, message: e.toString());
    }
  }

  Future<ProductsResponse> productsGet() async {
    final url = Uri.parse("${baseUrl}products");

    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
      });

      var data = jsonDecode(response.body);

      logger.d("Get Product : ${data["data"]}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProductsResponse.fromJson(data);
      } else {
        return ProductsResponse(error: false, message: data["message"]);
      }
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Get Product : Tidak ada koneksi internet");

      return ProductsResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("Get Product : ${e}");
      return ProductsResponse(
          error: true, message: "Terjadi kesalahan saat mengambil data produk");
    }
  }

  Future<FavoritesResponse> getUserFavorites() async {
    final url = Uri.parse("${baseUrl}favorites");
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token}'
      });

      var data = jsonDecode(response.body);

      logger.d("Get Favorite : ${data}");

      return FavoritesResponse.fromJson(data);
      
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Get Favorite : Tidak ada koneksi internet");
      return FavoritesResponse(error: true, message: NO_INTERNET_CONNECTION);
    } catch (e) {
      logger.e("Get Favorite : ${e}");
      return FavoritesResponse(error: true, message: SOMETHING_WAS_WRONG);
    }
  }

  Future<FavoriteResponse> favoriteDelete(int id) async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    final url = Uri.parse("${baseUrl}favorite");
    final response = await http.delete(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token}'
        },
        body: jsonEncode(<String, dynamic>{"id": id}));

    try {
      var data = jsonDecode(response.body);

      logger.d("Delete Favorite : ${data}");

      FavoriteResponse favoriteResponse = FavoriteResponse.fromJson(data);

      return favoriteResponse;
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Get Favorite : Tidak ada koneksi internet");

      return FavoriteResponse(message: NO_INTERNET_CONNECTION, error: true);
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
          'Authorization': 'Bearer ${token}'
        },
        body: jsonEncode(<String, dynamic>{"product_id": favorite.productId}));

    try {
      var data = jsonDecode(response.body);

      logger.d("Add Favorite : ${data}");

      FavoriteResponse favoriteResponse = FavoriteResponse.fromJson(data);

      return favoriteResponse;
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Get Favorite : Tidak ada koneksi internet");

      return FavoriteResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("Add Favorite : $e");
      return FavoriteResponse(error: true, message: "Network error : $e");
    }
  }

  Future<TermConditionResponse> termCondition() async {
    final url = Uri.parse("${baseUrl}term-condition");
    final response = await http.get(url,
        headers: <String, String>{'Content-Type': 'application/json'});

    TermConditionResponse termConditionResponse;
    try {
      var data = jsonDecode(response.body);

      logger.d("Term Condition : ${data}");
      termConditionResponse = TermConditionResponse.fromJson(data);
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Get Favorite : Tidak ada koneksi internet");
      termConditionResponse =
          TermConditionResponse(error: true, data: NO_INTERNET_CONNECTION);
    } catch (e) {
      logger.e("Term Condition : $e");
      termConditionResponse =
          TermConditionResponse(error: true, data: SOMETHING_WAS_WRONG);
    }
    return termConditionResponse;
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
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Get Favorite : Tidak ada koneksi internet");
      return NO_INTERNET_CONNECTION;
    } catch (e) {
      logger.e("Size Guide : $e");
      return "Network error : $e";
    }
  }

  Future<AppBannerResponse> getAllAppBanner() async {
    final url = Uri.parse("${baseUrl}app-banner");
    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
      });

      var data = jsonDecode(response.body);
      logger.d("get all app banner : ${data}");

      AppBannerResponse responseBody = AppBannerResponse.fromJson(data);
      return responseBody;
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("get all app banner : Tidak ada koneksi internet");
      return AppBannerResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("get all app banner : $e");

      return AppBannerResponse(message: "Network error : $e", error: true);
    }
  }

  // Function to upload SVG design to the server
  Future<CustomDesignResponse?> uploadCustomDesign(File file) async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    final url = Uri.parse("${baseUrl}order/custom-design");

    try {
      var request = http.MultipartRequest('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..headers['Authorization'] = 'Bearer ${token}'
        ..files.add(await http.MultipartFile.fromPath('file', file.path,
            contentType: MediaType('image', 'svg+xml')));

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = await response.stream.bytesToString();
        return CustomDesignResponse.fromJson(jsonDecode(responseData));
      } else {
        return CustomDesignResponse(
            error: true, message: 'Failed to upload file');
      }
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);
      logger.e("upload custom design : Tidak ada koneksi internet");
      return CustomDesignResponse(
          error: true, message: 'Tidak ada koneksi internet');
    } catch (e) {
      logger.e("upload custom design : Terjadi kesalahan");
      return CustomDesignResponse(error: true, message: 'Terjadi kesalahan');
    }
  }

  // Function to retrieve SVG design from the server
  Future<Map<String, dynamic>?> getCustomDesign(String filename) async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    final url = Uri.parse("${baseUrl}order/custom-design/$filename");

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer Bearer ${token}',
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Return file or response as needed
        return {'error': false, 'data': response.body};
      } else {
        return {'error': true, 'message': 'File not found'};
      }
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);
      logger.e("get custom design : Tidak ada koneksi internet");
    } catch (e) {
      showSnackBar(context, "Terjadi kesalahan", isError: true);
      logger.e("get custom design : Tidak ada koneksi internet");
    }
  }

  Future<ProductTermResponse> getProductTerm() async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    final url = Uri.parse("${baseUrl}product-terms");

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token}',
      });

      var data = jsonDecode(response.body);
      logger.d("get all app banner : ${data}");

      return ProductTermResponse.fromJson(data);
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);
      logger.e("get Product Term : Tidak ada koneksi internet");
      return ProductTermResponse(error: true, message: NO_INTERNET_CONNECTION);
    } catch (e) {
      logger.e("get Product Term : Terjadi kesalahan $e");
      return ProductTermResponse(error: true, message: "Terjadi kesalahan");
    }
  }

  Future<CareGuideResponse> getCareGuide() async {
    final url = Uri.parse("${baseUrl}care-guide");
    final response = await http.get(url,
        headers: <String, String>{'Content-Type': 'application/json'});

    CareGuideResponse careGuideResponse;
    try {
      var data = jsonDecode(response.body);
      logger.d("Care Guide : ${data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        careGuideResponse = CareGuideResponse.fromJson(data);
      } else if (response.statusCode >= 500) {
        careGuideResponse =
            CareGuideResponse(error: true, message: SOMETHING_WAS_WRONG_SERVER);
      } else {
        careGuideResponse =
            CareGuideResponse(error: true, message: SOMETHING_WAS_WRONG);
      }
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Care Guide :  Tidak ada koneksi internet");
      careGuideResponse =
          CareGuideResponse(error: true, message: NO_INTERNET_CONNECTION);
    } catch (e) {
      logger.e("Care Guide :  $e");
      careGuideResponse =
          CareGuideResponse(error: true, message: SOMETHING_WAS_WRONG);
    }
    return careGuideResponse;
  }

  Future<ProductNoteResponse> getNoteProduct(int type) async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    var url = Uri.parse("${baseUrl}product-note?type=${type}");

    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token}',
    });

    try {
      var data = jsonDecode(response.body);
      logger.d("Product Note : ${data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProductNoteResponse.fromJson(data);
      } else if (response.statusCode >= 500) {
        return ProductNoteResponse(
            error: true, message: SOMETHING_WAS_WRONG_SERVER);
      } else if (response.statusCode == 401) {
        showDialogSession(context);
        return
            ProductNoteResponse(error: true, message: UNAUTHORIZED);
      } else {
        return
            ProductNoteResponse(error: true, message: SOMETHING_WAS_WRONG);
      }
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Product Note : Tidak ada koneksi internet");
      return
          ProductNoteResponse(error: true, message: NO_INTERNET_CONNECTION);
    } catch (e) {
      logger.e("Product Note :  $e");
      return
          ProductNoteResponse(error: true, message: SOMETHING_WAS_WRONG);
    }
  }

  Future<DesignerResponse> getDesigner() async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    var url = Uri.parse("${baseUrl}designer");

    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token}',
    });

    DesignerResponse designerResponse;
    try {
      var data = jsonDecode(response.body);
      logger.d("Get Designer : ${data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        designerResponse = DesignerResponse.fromJson(data);
      } else if (response.statusCode >= 500) {
        designerResponse =
            DesignerResponse(error: true, message: SOMETHING_WAS_WRONG_SERVER);
      } else if (response.statusCode == 401) {
        showDialogSession(context);
        designerResponse = DesignerResponse(error: true, message: UNAUTHORIZED);
      } else {
        designerResponse =
            DesignerResponse(error: true, message: SOMETHING_WAS_WRONG);
      }
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Get Designer : Tidak ada koneksi internet");
      designerResponse =
          DesignerResponse(error: true, message: NO_INTERNET_CONNECTION);
    } catch (e) {
      logger.e("Get Designer :  $e");
      designerResponse =
          DesignerResponse(error: true, message: SOMETHING_WAS_WRONG);
    }
    return designerResponse;
  }

  Future<CustomizationAccessResponse> getCustomizationFeature() async {
    var url = Uri.parse("${baseUrl}app-feature?type=CUSTOMIZATION");

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      logger.d("Customization Feature Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = jsonDecode(response.body);
        return CustomizationAccessResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        showDialogSession(context);
        return CustomizationAccessResponse(error: true, message: UNAUTHORIZED);
      } else if (response.statusCode >= 500) {
        return CustomizationAccessResponse(
            error: true, message: SOMETHING_WAS_WRONG_SERVER);
      } else {
        return CustomizationAccessResponse(
            error: true, message: SOMETHING_WAS_WRONG);
      }
    } on SocketException {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);
      logger.e("Customization Feature: Tidak ada koneksi internet");
      return CustomizationAccessResponse(
          error: true, message: NO_INTERNET_CONNECTION);
    } catch (e) {
      logger.e("Customization Feature: $e");
      return CustomizationAccessResponse(
          error: true, message: SOMETHING_WAS_WRONG);
    }
  }

  Future<BuyFeatureResponse> buyCostumizationFeature() async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    final url = Uri.parse("${baseUrl}app-feature/buy?type=CUSTOMIZATION");
    final response = await http.post(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token}'
    });

    BuyFeatureResponse buyFeatureResponse;
    try {
      var data = jsonDecode(response.body);

      logger.d("Buy Customization Feature : ${data}");

      buyFeatureResponse = BuyFeatureResponse.fromJson(data);
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Buy Customization Feature : Tidak ada koneksi internet");

      buyFeatureResponse =
          BuyFeatureResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("Buy Customization Feature : $e");
      buyFeatureResponse =
          BuyFeatureResponse(error: true, message: "Network error : $e");
    }
    return buyFeatureResponse;
  }

  Future<OrderFeatureResponse> getFeatureOrder(String orderId) async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    final url = Uri.parse("${baseUrl}app-feature/buy/${orderId}");
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token}'
    });

    try {
      var data = jsonDecode(response.body);

      logger.d("Get Feature Order : ${data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OrderFeatureResponse.fromJson(data);
      } else if (response.statusCode >= 500) {
        return OrderFeatureResponse(
            error: true, message: SOMETHING_WAS_WRONG_SERVER);
      } else if (response.statusCode == 401) {
        showDialogSession(context);
        return OrderFeatureResponse(error: true, message: UNAUTHORIZED);
      } else {
        return OrderFeatureResponse(error: true, message: SOMETHING_WAS_WRONG);
      }
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("Get Feature Order : Tidak ada koneksi internet");
      return OrderFeatureResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("Get Feature Order: ${e}");
      return OrderFeatureResponse(error: true, message: "Network error : $e");
    }
  }


  Future<LookAccessResponse> getLookAccess(String lookId) async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    final url = Uri.parse("${baseUrl}look/${lookId}");
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token}'
    });

    try {
      var data = jsonDecode(response.body);

      logger.d("look Access : ${data}");

      return LookAccessResponse.fromJson(data);
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("look Access : Tidak ada koneksi internet");

      return LookAccessResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("look Access : $e");
      return  LookAccessResponse(error: true, message: "Network error : $e");
    }
  }


  Future<LookOrderResponse> buyLook(String lookId) async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    final url = Uri.parse("${baseUrl}look/buy");
    final response = await http.post(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token}'
    },body: jsonEncode( <String, String>{
      "look_id" : lookId
    }));

    try {
      var data = jsonDecode(response.body);

      logger.d("look order : ${data}");

      return LookOrderResponse.fromJson(data);
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("look order : Tidak ada koneksi internet");

      return LookOrderResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("look order : $e");
      return  LookOrderResponse(error: true, message: "Network error : $e");
    }
  }


  Future<LookOrderResponse> getLookOrder(String lookId) async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);
    final url = Uri.parse("${baseUrl}look/buy/${lookId}");
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token}'
    });

    try {
      var data = jsonDecode(response.body);

      logger.d("get look order : ${data}");

      return LookOrderResponse.fromJson(data);
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("get look order : Tidak ada koneksi internet");

      return LookOrderResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("get look order : $e");
      return  LookOrderResponse(error: true, message: "Network error : $e");
    }
  }


  Future<CityResponse> getListCity() async {
    final url = Uri.parse("${baseUrl}shipping/cities");
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json'
    });

    try {
      var data = jsonDecode(response.body);

      logger.d("get city response : ${data}");

      return CityResponse.fromJson(data);
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("get city response : Tidak ada koneksi internet");

      return CityResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("get city response : $e");
      return  CityResponse(error: true, message: "Network error : $e");
    }
  }

  Future<ProvinceResponse> getListProvinces() async {
    final url = Uri.parse("${baseUrl}shipping/provinces");
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json'
    });

    try {
      var data = jsonDecode(response.body);

      logger.d("get province response : ${data}");

      return ProvinceResponse.fromJson(data);
    } on SocketException catch (e) {
      showSnackBar(context, NO_INTERNET_CONNECTION, isError: true);

      logger.e("get province response : Tidak ada koneksi internet");

      return ProvinceResponse(message: NO_INTERNET_CONNECTION, error: true);
    } catch (e) {
      logger.e("get province response : $e");
      return  ProvinceResponse(error: true, message: "Network error : $e");
    }
  }

}
