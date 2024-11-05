

class User {
  String email;
  String name;
  String phoneNumber;
  String password;
  String address;
  String imgUrl;

  User({required this.email,this.password = "",required this.name,this.phoneNumber = "",this.address = "", this.imgUrl = ""});
  

   factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['id'],
      name: json['name'],
      phoneNumber: json['phone_number'] ?? "",
      address: json['address'] ?? "",
      imgUrl: json['img_url'] ?? "",
    );
  }
}