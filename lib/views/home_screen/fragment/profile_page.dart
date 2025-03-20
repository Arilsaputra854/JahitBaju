import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/model/user.dart';
import 'package:jahit_baju/data/source/remote/response/user_response.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/profile_view_model.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  var deviceWidth;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();

    ProfileViewModel viewModel =
        Provider.of<ProfileViewModel>(context, listen: false);
    viewModel.init();
    viewModel.loadUserFromDatabase().then((_) {
      if (mounted && viewModel.user != null) {
        nameController.text = viewModel.user!.name ?? "";
        emailController.text = viewModel.user!.email ?? "";
        phoneController.text = viewModel.user!.phoneNumber ?? "";
        passwordController.text =  "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;

    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
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
                                  viewModel.user?.imageUrl?.isNotEmpty == true
                                      ? Image.network(viewModel.user!.imageUrl!,
                                          fit: BoxFit.cover)
                                      : Image.asset("assets/icon/profile.png"),
                            ),
                          )),
                      SizedBox(height: deviceWidth * 0.01),
                      InkWell(
                        onTap: () {
                          if (!viewModel.onEdit) {
                            passwordController.text = ""; 
                            viewModel.setOnEdit(); // Aktifkan mode edit
                          } else {
                            saveSetting(
                                viewModel); // Simpan data jika mode edit sudah aktif
                            viewModel
                                .setOnEdit(); // Matikan mode edit setelah menyimpan
                          }
                        },
                        child: Container(
                          width: deviceWidth,
                          child: Text(
                            viewModel.onEdit ? "Simpan Data" : "Ubah Data",
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
                        enabled: viewModel.onEdit,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Kolom ini tidak boleh kosong!";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                        decoration: standartInputDecoration(
                            viewModel.user?.name ?? "name", Icons.person),
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
                            viewModel.user?.email ?? "email", Icons.email),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        style: TextStyle(fontSize: 12.sp),
                        controller: phoneController,
                        enabled: viewModel.onEdit,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Kolom ini tidak boleh kosong!";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        decoration: standartInputDecoration(
                            viewModel.user?.phoneNumber != "" &&
                                    viewModel.user?.phoneNumber != null
                                ? viewModel.user!.phoneNumber
                                : "Phone Number",
                            Icons.phone),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        style: TextStyle(fontSize: 12.sp),
                        controller: passwordController,
                        enabled: viewModel.onEdit,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Kolom ini tidak boleh kosong!";
                          }
                          return null;
                        },
                        obscureText: true,
                        decoration: standartInputDecoration(
                          
                            viewModel.onEdit ? "Masukkan password baru" : "***********",
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
            )));
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

  Future<void> saveSetting(ProfileViewModel viewModel) async {
    ApiService apiService = ApiService(context);

    UserResponse response = await apiService.userUpdate(
      nameController.text,
      emailController.text,
      passwordController.text.isNotEmpty || passwordController.text !=viewModel.user!.password? passwordController.text : viewModel.user!.password,
      null,
      null,
      phoneController.text,
    );

    if (response.error) {
      Fluttertoast.showToast(msg: response.message!);
    } else {
      Fluttertoast.showToast(msg: "Data berhasil diupdate!");
      viewModel.loadUserFromDatabase();
    }
  }

  void editProfilePicture() {
    openGallery();
  }

  void openGallery() {}
}
