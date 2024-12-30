import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/helper/app_color.dart';
import 'package:jahit_baju/service/remote/api_service.dart';
import 'package:jahit_baju/service/remote/response/user_response.dart';

class AddressScreen extends StatefulWidget {
  String? currentAddress;
  AddressScreen(this.currentAddress, {super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();

  ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    if (widget.currentAddress != null) {
      _addressController.text = widget.currentAddress!;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ubah Alamat"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Alamat Lengkap",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Masukkan alamat lengkap Anda",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Alamat tidak boleh kosong";
                  }
                  if (value.length < 10) {
                    return "Alamat harus terdiri dari minimal 10 karakter";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Center(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          backgroundColor: AppColor.primary),
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          updateAddressUser(_addressController.text);
                        }
                      },
                      child: const Text(
                        "Simpan Alamat",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white),
                      ))),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateAddressUser(String newAddress) async {
    UserResponse response =
        await apiService.userUpdate(null, null, null, null, newAddress, null);
    if (response.error) {
      Fluttertoast.showToast(msg: response.message!);
    }else{
      Fluttertoast.showToast(msg: "Alamat berhasil diupdate!");
      Navigator.pop(context);
    }
  }
}
