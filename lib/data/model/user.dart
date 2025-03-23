class User {
  String id;
  String email;
  String name;
  String phoneNumber;
  String password;
  String? addressId;
  String? imageUrl;
  bool emailVerified;
  bool customAccess;
  String role;
  DateTime? lastUpdate;
  String? token;
  String? refreshToken;
  Address? address;

  User({
    this.id = "",
    required this.email,
    required this.name,
    this.phoneNumber = "",
    required this.password,
    this.addressId,
    this.imageUrl,
    this.emailVerified = false,
    this.customAccess = false,
    this.role = "User",
    this.lastUpdate,
    this.token,
    this.refreshToken,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? "",
      email: json['email'] ?? "",
      name: json['name'] ?? "",
      phoneNumber: json['phone_number'] ?? "",
      password: json['password'] ?? "",
      addressId: json['address_id'],
      imageUrl: json['img_url'],
      emailVerified: json['email_verified'] ?? false,
      customAccess: json['custom_access'] ?? false,
      role: json['role'] ?? "User",
      lastUpdate: json['last_update'] != null ? DateTime.parse(json['last_update']) : null,
      token: json['token'],
      refreshToken: json['refresh_token'],
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone_number': phoneNumber,
      'password': password,
      'address_id': addressId,
      'img_url': imageUrl,
      'email_verified': emailVerified,
      'custom_access': customAccess,
      'role': role,
      'last_update': lastUpdate?.toIso8601String(),
      'token': token,
      'refresh_token': refreshToken,
      'address': address?.toJson(),
    };
  }
}

class Address {
  String? id;
  String streetAddress;
  String? rt;
  String? rw;
  String? district;
  String? village;
  String? city;
  String? province;
  int? postalCode;
  DateTime? createdAt;
  DateTime? updatedAt;

  Address({
    this.id,
    required this.streetAddress,
    this.rt,
    this.rw,
    this.district,
    this.village,
    required this.city,
    required this.province,
    required this.postalCode,
    this.createdAt,
    this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? "",
      streetAddress: json['street_address'] ?? "",
      rt: json['rt'] ?? "",
      rw: json['rw'] ?? "",
      district: json['district'] ?? null,
      village: json['village'] ?? null,
      city: json['city'],
      province: json['province'] ?? null,
      postalCode: json['postal_code'] ?? null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street_address': streetAddress,      
      'city': city.toString(),
      'province': province.toString(),
      'postal_code': postalCode,
      'district' : district.toString(),
      'village' : village.toString(),
    };
  }
}
