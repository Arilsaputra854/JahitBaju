class User {
  String id;
  String email;
  String name;
  String phoneNumber;
  String password;
  String? address;
  String imageUrl;
  bool emailVerified;
  bool customAccess;
  final DateTime? lastUpdate;

  User({
    this.id = "",
    required this.email,
    required this.name,
     this.phoneNumber= "",
    required this.password,
     this.address,
     this.imageUrl= "",
    this.emailVerified = false,
    this.customAccess = false,
    this.lastUpdate,
  });
factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? "",  // Use empty string if 'id' is null
      email: json['email'] ?? "",  // Use empty string if 'email' is null
      name: json['name'] ?? "",  // Use empty string if 'name' is null
      phoneNumber: json['phone_number']?? "",  // Nullable field
      password: json['password'] ?? "",  // Use empty string if 'password' is null
      address: json['address'],  // Nullable field
      imageUrl: json['img_url']?? "",  // Nullable field
      emailVerified: json['email_verified'] ?? false,
      customAccess: json['custom_access'] ?? false,
      lastUpdate: json['last_update'] != null ? DateTime.parse(json['last_update']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone_number': phoneNumber,
      'password': password,
      'address': address,
      'img_url': imageUrl,
      'email_verified' : emailVerified,
      'custom_access' : customAccess,
      'last_update': lastUpdate?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}
