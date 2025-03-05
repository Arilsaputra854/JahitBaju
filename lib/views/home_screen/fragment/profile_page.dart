import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/data/model/user.dart';
import 'package:jahit_baju/data/source/remote/response/user_response.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/views/login/login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _HomePageState();
}

class _HomePageState extends State<ProfilePage> {
  late bool onEdit, enabled;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController passwordController;
  var deviceWidth;
  @override
  void initState() {
    super.initState();
    onEdit = false;
    enabled = false;
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: loadUserFromDatabase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            enabled = false;
          } else if (snapshot.hasData) {
            enabled = true;
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
                    Container(
                        width: deviceWidth * 0.3,
                        height: deviceWidth * 0.3,
                        child: InkWell(
                          onTap: () {
                            editProfilePicture();
                          },
                          child: ClipOval(
                            child:
                                user?.imageUrl == "" || user?.imageUrl == null
                                    ? Image.asset("assets/icon/profile.png")
                                    : Image.network(user!.imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity),
                          ),
                        )),
                    SizedBox(height: deviceWidth * 0.01),
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
                          onEdit ? "Simpan Data" : "Ubah Data",
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: Color.fromARGB(255, 141, 120, 119)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      style: TextStyle(fontSize: 12.sp),
                      controller: nameController,
                      enabled: onEdit,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Kolom ini tidak boleh kosong!";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.name,
                      decoration: standartInputDecoration(
                          user?.name ?? "name", Icons.person),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      style: TextStyle(fontSize: 12.sp),
                      controller: emailController,
                      enabled: false,
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
                      style: TextStyle(fontSize: 12.sp),
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
                      style: TextStyle(fontSize: 12.sp),
                      controller: addressController,
                      enabled: onEdit,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Kolom ini tidak boleh kosong!";
                        }
                        return null;
                      },
                      decoration: standartInputDecoration(
                          user?.address??"Alamat",
                          Icons.location_pin),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      style: TextStyle(fontSize: 12.sp),
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
                    SizedBox(height: deviceWidth * 0.03),
                    InkWell(
                      onTap: () => logoutUser(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Logout",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14.sp),
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
      ),
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


  Future<User> loadUserFromDatabase() async {

    UserResponse response = await ApiService(context).userGet();

    if(!response.error){
      return response.data ?? User(
        email: "email",
        name: "name",
        password: "password",
        emailVerified: false);
    }
    Fluttertoast.showToast(msg: "Tidak dapat memperbarui halaman.");
    return User(
        email: "email",
        name: "name",
        password: "password",
        emailVerified: false);
  }


  Future<void> saveSetting() async {
    ApiService apiService = ApiService(context);


    UserResponse response =  await apiService
          .userUpdate(
        nameController.text,
        emailController.text,
        passwordController.text,
        null,
        addressController.text,
        phoneController.text,
      );

    if(response.error){

        Fluttertoast.showToast(msg: response.message!);
    }else{

        Fluttertoast.showToast(msg: "Data berhasil diupdate!");

        loadUserFromDatabase();
        setState(() {});
    }

  }

  void editProfilePicture() {
    openGallery();
  }

  void openGallery() {}
}