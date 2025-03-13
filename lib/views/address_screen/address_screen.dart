import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/model/city.dart';
import 'package:jahit_baju/data/model/province.dart';
import 'package:jahit_baju/data/model/user.dart';
import 'package:jahit_baju/helper/app_color.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/user_response.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/address_view_model.dart';
import 'package:provider/provider.dart';

class AddressScreen extends StatefulWidget {
  Address? currentAddress;
  AddressScreen(this.currentAddress, {super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();

  late ApiService apiService;
  bool loading = false;

  @override
  void initState() {
    apiService = ApiService(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentAddress != null) {
      _addressController.text = widget.currentAddress!.streetAddress;
    }

    return Consumer<AddressViewModel>(
      builder: (context, viewmodel, child) {
        return Stack(
          children: [
            Scaffold(
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
                      _addressWidget(),
                      const SizedBox(height: 16),
                      _cityWidget(viewmodel),
                      const SizedBox(height: 16),
                      _provinceWidget(viewmodel),
                      const SizedBox(height: 16),
                      Center(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  backgroundColor: AppColor.primary),
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  setState(() {
                                    loading = true;
                                  });
                                  updateAddressUser(
                                      _addressController.text, viewmodel);
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
            ),
            if (loading) loadingWidget()
          ],
        );
      },
    );
  }

  Future<void> updateAddressUser(
      String newAddress, AddressViewModel viewmodel) async {
    Address address = new Address(
        streetAddress: newAddress,
        city: int.parse(viewmodel.selectedCity!.cityId),
        province: int.parse(viewmodel.selectedProvince!.provinceId),
        postalCode: int.parse(viewmodel.selectedCity!.postalCode));
    UserResponse response =
        await apiService.userUpdate(null, null, null, null, address, null);
    if (response.error) {
      Fluttertoast.showToast(msg: response.message!);
    } else {
      Fluttertoast.showToast(msg: "Alamat berhasil diupdate!");
      Navigator.pop(context);
    }
    setState(() {
      loading = false;
    });
  }

  _addressWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Alamat Lengkap",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _addressController,
          maxLines: 3,
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
        )
      ],
    );
  }

  _cityWidget(AddressViewModel viewmodel) {
    return FutureBuilder(
      future: viewmodel.fetchListCity(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          //saya mau kode for ini berjalan sekali
          if (viewmodel.selectedCity == null) {
            for (City element in snapshot.data!) {
              if (widget.currentAddress!.city == int.parse(element.cityId)) {
                viewmodel.setSelectedCity(element);
              }
            }
          }
          return DropdownButtonFormField<City>(
            value: viewmodel.selectedCity,
            hint: const Text("Pilih Kota"),
            isExpanded: true,
            items: snapshot.data!.map((City city) {
              return DropdownMenuItem<City>(
                value: city,
                child: Text("${city.type} ${city.cityName}"),
              );
            }).toList(),
            onChanged: (City? newValue) {
              if (newValue != null) {
                viewmodel.setSelectedCity(newValue);
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            ),
          );
        }
        return itemCartShimmer();
      },
    );
  }

  _provinceWidget(AddressViewModel viewmodel) {
    return FutureBuilder(
      future: viewmodel.fetchListProvince(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          if (viewmodel.selectedCity == null) {
            for (Province element in snapshot.data!) {
              if (widget.currentAddress!.province ==
                  int.parse(element.provinceId)) {
                viewmodel.setSelectedProvince(element);
              }
            }
          }

          return DropdownButtonFormField<Province>(
            value: viewmodel.selectedProvince,
            hint: const Text("Pilih Provinsi"),
            isExpanded: true,
            items: snapshot.data!.map((Province province) {
              return DropdownMenuItem<Province>(
                value: province,
                child: Text("${province.provinceName}"),
              );
            }).toList(),
            onChanged: (Province? newValue) {
              if (newValue != null) {
                viewmodel.setSelectedProvince(newValue);
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            ),
          );
        }
        return itemCartShimmer();
      },
    );
  }
}
