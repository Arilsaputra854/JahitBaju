import 'package:flutter/material.dart';
import 'package:jahit_baju/api/api_service.dart';
import 'package:jahit_baju/model/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _HomePageState();
}

class _HomePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(future: loadUserFromDatabase(), builder: (context, snapshot){

      if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Show loading indicator while waiting
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}")); // Show error if something goes wrong
        } else if (!snapshot.hasData) {
          return Center(child: Text("No user data found")); // Show message if no user data is returned
        }

        // Get the user data once it's loaded
        User user = snapshot.data!;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 40),
        width: deviceWidth,
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              Container(
                width: 200,
                height: 200,
                child: ClipOval(
                  child: user.imageUrl == ""
                      ? Icon(
                          Icons.person,
                          size: 200,
                        )
                      : Image.network(
                          user.imageUrl,
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                user.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              SizedBox(
                height: 40,
              ),
              TextFormField(
                enabled: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Kolom ini tidak boleh kosong!";
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: standartInputDecoration(user.email, Icons.email),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                enabled: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Kolom ini tidak boleh kosong!";
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: standartInputDecoration(
                    user.phoneNumber != "" ? user.phoneNumber : "Phone Number",
                    Icons.phone),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                enabled: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Kolom ini tidak boleh kosong!";
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: standartInputDecoration(
                    user.address != "" ? user.address : "Address",
                    Icons.location_pin),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                enabled: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Kolom ini tidak boleh kosong!";
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: standartInputDecoration(
                    user.password != "" ? user.password : "***********",
                    Icons.password),
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Logout",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(
                width: 10,
              ),
                  Icon(Icons.logout)
                ],
              )
            ],
          ),
        ));
    });
  }

  standartInputDecoration(String hint, IconData icon) {
    return InputDecoration(
        errorStyle: TextStyle(color: Colors.white),
        fillColor: Colors.white,
        filled: true,
        suffixIcon: Icon(icon),
        suffixIconColor: Colors.black,
        hintText: hint,
        disabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        hintStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))));
  }
}

  Future<User> loadUserFromDatabase() async{
    var apiService =  await ApiService().userGet("f4734ade-8bcd-4ad7-8204-9b8ad681ca0a");

    if(apiService is User){
      return apiService as User;
    }
    return new User(email: "email", name: "name", password: "password");
  }