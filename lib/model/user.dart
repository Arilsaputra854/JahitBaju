class User {
  String id;
  String email;
  String name;
  String phoneNumber;
  String password;
  String address;
  String imageUrl;

  User({
    this.id = "",
    required this.email,
    required this.name,
     this.phoneNumber= "",
    required this.password,
     this.address= "",
     this.imageUrl= "",
  });
factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? "",  // Use empty string if 'id' is null
      email: json['email'] ?? "",  // Use empty string if 'email' is null
      name: json['name'] ?? "",  // Use empty string if 'name' is null
      phoneNumber: json['phone_number'],  // Nullable field
      password: json['password'] ?? "",  // Use empty string if 'password' is null
      address: json['address'],  // Nullable field
      imageUrl: json['img_url'],  // Nullable field
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
    };
  }
}
