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
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      password: json['password'],
      address: json['address'],
      imageUrl: json['image_url'],
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
      'image_url': imageUrl,
    };
  }
}
