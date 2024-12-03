import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
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
  late bool onEdit, enabled;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    onEdit = false;
    enabled = false;
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: loadUserFromDatabase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          enabled = false;
        } else if (snapshot.hasData) {
          onEdit = true;
        }

        // Initialize the controllers with user data
        nameController = TextEditingController();
        emailController = TextEditingController();
        phoneController = TextEditingController();
        addressController = TextEditingController();
        passwordController = TextEditingController();

        User? user = snapshot.data;

        // Set initial values for controllers
        nameController.text = user?.name ?? "";
        emailController.text = user?.email ?? "";
        phoneController.text = user?.phoneNumber ?? "";
        addressController.text = user?.address ?? "";
        passwordController.text = user?.password ?? "";

        //TODO REFRESH UI WHEN UPDATE SUCCESS
        return SingleChildScrollView(
            child: Container(
          color: Colors.white,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            width: deviceWidth,
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Container(
                    width: deviceWidth * 0.4,
                    height: deviceWidth * 0.4,
                    child: ClipOval(
                      child: user?.imageUrl == "" || user?.imageUrl == null
                          ? Center(child: const Icon(Icons.person, size: 150))
                          : Image.network(user!.imageUrl,
                              fit: BoxFit.cover, width: double.infinity),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.name ?? "",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  const SizedBox(height: 40),
                  InkWell(
                    onTap: () {
                      if (enabled) {
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
                      }
                    },
                    child: Container(
                      width: deviceWidth,
                      child: Text(
                        onEdit ? "Simpan Data" : "Edit Data",
                        style: const TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 141, 120, 119)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                    decoration: standartInputDecoration(
                        user?.email ?? "email", Icons.email),
                  ),
                  const SizedBox(height: 10),
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
                        user?.phoneNumber != "" && user?.phoneNumber != null
                            ? user!.phoneNumber
                            : "Phone Number",
                        Icons.phone),
                  ),
                  const SizedBox(height: 10),
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
                        user?.address != "" && user?.address != null
                            ? user!.address
                            : "Address",
                        Icons.location_pin),
                  ),
                  const SizedBox(height: 10),
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
                        user?.password != "" && user?.password != null
                            ? user!.password
                            : "***********",
                        Icons.password),
                  ),
                  const SizedBox(height: 40),
                  InkWell(
                    onTap: () => logoutUser(),
                    child: const Row(
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
        ));
      },
    );
  }

  standartInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      errorStyle: const TextStyle(color: Colors.white),
      fillColor: Colors.white,
      filled: true,
      suffixIcon: Icon(icon),
      suffixIconColor: Colors.black,
      hintText: hint,
      disabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      hintStyle:
          const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
      border: const OutlineInputBorder(
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
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false);
  }

  Future<void> saveSetting() async {
    String? token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

    ApiService apiService = ApiService();

    try {
      String? token = await tokenStorage.readToken(TokenStorage.TOKEN_KEY);

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
