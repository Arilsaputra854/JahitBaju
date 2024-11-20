import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/api/api_service.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/model/user.dart';
import 'package:jahit_baju/views/login/login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _HomePageState();
}

class _HomePageState extends State<ProfilePage> {
  TokenStorage tokenStorage = TokenStorage();
  late bool onEdit;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    onEdit = false;
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: loadUserFromDatabase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData) {
          return Center(child: Text("No user data found"));
        }

        // Initialize the controllers with user data
        nameController = TextEditingController();
        emailController = TextEditingController();
        phoneController = TextEditingController();
        addressController = TextEditingController();
        passwordController = TextEditingController();

        User user = snapshot.data!;

        // Set initial values for controllers
        nameController.text = user.name;
        emailController.text = user.email;
        phoneController.text = user.phoneNumber;
        addressController.text = user.address;
        passwordController.text = user.password;

        return Container(
          color: Colors.white,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            width: deviceWidth,
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Container(
                    width: 200,
                    height: 200,
                    child: ClipOval(
                      child: user.imageUrl == ""
                          ? Icon(Icons.person, size: 200)
                          : Image.network(
                              user.imageUrl,
                              fit: BoxFit.cover,
                              width: 200,
                              height: 200,
                            ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    user.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  SizedBox(height: 40),
                  InkWell(
                    onTap: () {
                      if (onEdit) {
                        // Save the settings and only then toggle edit mode
                        saveSetting();
                        setState(() {
                          onEdit = !onEdit; // Only toggle after save
                        });
                      } else {
                        setState(() {
                          onEdit = !onEdit; // Simply toggle edit mode
                        });
                      }
                    },
                    child: Container(
                      width: deviceWidth,
                      child: Text(
                        onEdit ? "Simpan Data" : "Edit Data",
                        style: TextStyle(
                            fontSize: 15,
                            color: const Color.fromARGB(255, 141, 120, 119)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    enabled: onEdit,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Kolom ini tidak boleh kosong!";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                        standartInputDecoration(user.email, Icons.email),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: phoneController,
                    enabled: onEdit,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Kolom ini tidak boleh kosong!";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.phone,
                    decoration: standartInputDecoration(
                        user.phoneNumber != ""
                            ? user.phoneNumber
                            : "Phone Number",
                        Icons.phone),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: addressController,
                    enabled: onEdit,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Kolom ini tidak boleh kosong!";
                      }
                      return null;
                    },
                    decoration: standartInputDecoration(
                        user.address != "" ? user.address : "Address",
                        Icons.location_pin),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    enabled: onEdit,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Kolom ini tidak boleh kosong!";
                      }
                      return null;
                    },
                    obscureText: true,
                    decoration: standartInputDecoration(
                        user.password != "" ? user.password : "***********",
                        Icons.password),
                  ),
                  SizedBox(height: 40),
                  InkWell(
                    onTap: () => logoutUser(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Logout",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.logout)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  standartInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      errorStyle: TextStyle(color: Colors.white),
      fillColor: Colors.white,
      filled: true,
      suffixIcon: Icon(icon),
      suffixIconColor: Colors.black,
      hintText: hint,
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      hintStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  }

  logoutUser() async {
    await tokenStorage.deleteToken(TokenStorage.TOKEN_KEY);
    Fluttertoast.showToast(msg: "Logout berhasil");
    goToLoginScreen();
  }

  Future<User> loadUserFromDatabase() async {
    var token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    if (token != null) {
      var apiService = await ApiService().userGet(token!);
      if (apiService is User) {
        return apiService as User;
      }
    }

    return User(email: "email", name: "name", password: "password");
  }

  void goToLoginScreen() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false);
  }

  Future<void> saveSetting() async {
    String? token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    ApiService apiService = ApiService();

    try {
      
      String? token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);;
      if (token != null) {
        await apiService
            .userUpdate(
          token,
          emailController.text,
          passwordController.text,
          null, // assuming imageUrl is not being updated
          addressController.text,
          phoneController.text,
        )
            .then((value) {
          if (value == "Unauthorized") {
            Fluttertoast.showToast(msg: "Token invalid, please log in");
          }
          Fluttertoast.showToast(msg: value.toString());

          loadUserFromDatabase();
        });
      } else {
        Fluttertoast.showToast(msg: "Token invalid, please log in");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to update: $e");
    }
  }
}
