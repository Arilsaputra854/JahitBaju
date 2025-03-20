import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:flutter_typeahead/flutter_typeahead.dart';

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
                      _postalCodeWidget(viewmodel),
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
                                  await viewmodel
                                      .updateAddressUser(
                                          _addressController.text, viewmodel)
                                      .then((user) {
                                    if (user != null) {
                                      Navigator.pop(context);
                                    }
                                  });
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

  Widget _cityWidget(AddressViewModel viewmodel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Kabupaten/Kota",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TypeAheadFormField<City>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: TextEditingController(
                text: viewmodel.selectedCity?.cityName ?? ""),
            decoration: InputDecoration(
              hintText: "Masukkan nama kota",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          suggestionsCallback: (pattern) async {
            return viewmodel.listOfCity
                    ?.where((city) => city.cityName
                        .toLowerCase()
                        .contains(pattern.toLowerCase()))
                    .toList() ??
                [];
          },
          itemBuilder: (context, City suggestion) {
            return ListTile(
              title: Text("${suggestion.type} ${suggestion.cityName}"),
            );
          },
          onSuggestionSelected: (City suggestion) {
            viewmodel.setSelectedCity(suggestion);
          },
          noItemsFoundBuilder: (context) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Kota tidak ditemukan"),
          ),
        ),
      ],
    );
  }

  Widget _postalCodeWidget(AddressViewModel viewmodel) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Kode Pos",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: TextEditingController(
            text: viewmodel.postalCode != null ? viewmodel.postalCode.toString() : ""),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly,LengthLimitingTextInputFormatter(5),],

        decoration: InputDecoration(
          hintText: "Masukkan Kode Pos",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onChanged: (value) {
          viewmodel.setPostalCode(int.parse(value));
        },
      ),
    ],
  );
}


  Widget _provinceWidget(AddressViewModel viewmodel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Provinsi",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TypeAheadFormField<Province>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: TextEditingController(
                text: viewmodel.selectedProvince?.provinceName ?? ""),
            decoration: InputDecoration(
              hintText: "Masukkan nama provinsi",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          suggestionsCallback: (pattern) async {
            return viewmodel.listOfProvince
                    ?.where((province) => province.provinceName
                        .toLowerCase()
                        .contains(pattern.toLowerCase()))
                    .toList() ??
                [];
          },
          itemBuilder: (context, Province suggestion) {
            return ListTile(
              title: Text(suggestion.provinceName),
            );
          },
          onSuggestionSelected: (Province suggestion) {
            viewmodel.setSelectedProvince(suggestion);
          },
          noItemsFoundBuilder: (context) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Provinsi tidak ditemukan"),
          ),
        ),
      ],
    );
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
}
