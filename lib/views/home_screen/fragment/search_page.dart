import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/repository/repository.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/product_response.dart';
import 'package:jahit_baju/helper/app_color.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/search_view_model.dart';
import 'package:jahit_baju/views/home_screen/fragment/home_page.dart';
import 'package:jahit_baju/views/product_screen/product_screen.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var searchController = TextEditingController();

  List<Product>? productsRTW;
  List<Product>? productsCustom;
  List<Product>? filteredRTW;
  List<Product>? filteredCustom;

  Logger logger = Logger();

  bool accessCustom = false;
  String? _selectedCategory;
  String? _selectedTags;
  String? _searchQuery;

  List<String> categories = [];
  List<String> tags = [];

  var deviceWidth;


  @override
  Widget build(BuildContext context) {
    initializeSort();

    deviceWidth = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
        create: (context) => SearchViewModel(Repository(ApiService(context))),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(120),
            child: AppBar(
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                flexibleSpace: Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          // TextField untuk Input Pencarian
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: "Search",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 16),
                              ),
                            ),
                          ),
                          const SizedBox(
                              width: 8), // Jarak antara TextField dan Icon

                          Material(
                            shape: CircleBorder(side: BorderSide(width: 1)),
                            child: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                _searchQuery = searchController.text;

                                searchProduct(_searchQuery ?? "");
                              },
                            ),
                          )
                        ],
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            children: [
                              DropdownButton(
                                hint: Text("Kategori"),
                                value: _selectedCategory,
                                items: categories.map((value) {
                                  return DropdownMenuItem(
                                    child: Text(value),
                                    value: value,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value!;
                                  });
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              DropdownButton(
                                hint: Text("Tag Produk"),
                                value: _selectedTags,
                                items: tags.map((value) {
                                  return DropdownMenuItem(
                                    child: Text(value),
                                    value: value,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedTags = value!;
                                  });
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              _selectedCategory != null || _selectedTags != null
                                  ? InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedCategory = null;
                                          _selectedTags = null;

                                          filteredRTW = List.from(productsRTW!);
                                          filteredCustom =
                                              List.from(productsCustom!);
                                        });
                                      },
                                      child: Text(
                                        "Hapus filter",
                                        style: TextStyle(
                                          color: AppColor.primary,
                                        ),
                                      ))
                                  : Container()
                            ],
                          ))
                    ],
                  ),
                )),
          ),
          backgroundColor: Colors.white,
          body: Consumer<SearchViewModel>(builder: (context, viewModel, child) {
            return FutureBuilder(
                future: viewModel.getListProducts(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // Menampilkan data atau place holder
                    List<Product>? products = snapshot.data;

                    productsRTW = products
                        ?.where(
                            (product) => product.type == Product.READY_TO_WEAR)
                        .toList();
                    productsCustom = products
                        ?.where((product) => product.type == Product.CUSTOM)
                        .toList();

                    if (_selectedTags != null && _selectedTags!.isNotEmpty) {
                      filteredRTW = productsRTW
                          ?.where((product) => product.tags
                              .any((tag) => _selectedTags!.contains(tag)))
                          .toList();
                      filteredCustom = productsCustom
                          ?.where((product) => product.tags
                              .any((tag) => _selectedTags!.contains(tag)))
                          .toList();
                    }

                    if (_selectedCategory != null &&
                        _selectedCategory!.isNotEmpty) {
                      filteredRTW = productsRTW?.where((product) {
                        if (product.category != null &&
                            product.category!.isNotEmpty) {
                          return product.category!.any((category) =>
                              _selectedCategory!.contains(category));
                        } else {
                          return false;
                        }
                      }).toList();

                      filteredCustom = productsCustom?.where((product) {
                        if (product.category != null &&
                            product.category!.isNotEmpty) {
                          return product.category!.any((category) =>
                              _selectedCategory!.contains(category));
                        } else {
                          return false;
                        }
                      }).toList();
                    }

                    if (filteredRTW == null)
                      filteredRTW = List.from(productsRTW!);
                    if (filteredCustom == null)
                      filteredCustom = List.from(productsCustom!);

                    if ((_selectedCategory == null && _selectedTags == null) &&
                        _searchQuery == null) {
                      filteredRTW = List.from(productsRTW!);
                      filteredCustom = List.from(productsCustom!);
                    }

                    return SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Center(
                              child: Text("Siap Pakai",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: deviceWidth * 0.04)),
                            )),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: widgetListRTW(),
                        ),
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Center(
                              child: Text("Custom Produk",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: deviceWidth * 0.04)),
                            )),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: widgetListCustom(viewModel),
                        )
                      ],
                    ));
                  }
                  return productShimmer();
                });
          }),
        ));
  }

  void searchProduct(String text) {
    filterProducts(text);
  }

  void filterProducts(String query) {
    if (productsRTW != null && productsCustom != null) {
      setState(() {
        filteredRTW = productsRTW!
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        filteredCustom = productsCustom!
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void goToProductScreen(Product item) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProductScreen(item)));
  }

  widgetListRTW() {
    return Container(
        margin: const EdgeInsets.all(10),
        child: filteredRTW != null
            ? filteredRTW!.isNotEmpty
                ? GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 0.7,
                        crossAxisSpacing:
                            10.0, // Jarak antar item di sumbu horizontal (kanan)
                        mainAxisSpacing: 10.0,
                        crossAxisCount: 2),
                    itemCount: filteredRTW?.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            goToProductScreen(filteredRTW![index]);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(width: 1)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: CachedNetworkImage(
                                      imageUrl: filteredRTW![index].imageUrl[0],
                                      placeholder: (context, url) {
                                        return Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              color: Colors.grey,
                                            ));
                                      },
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                    margin: EdgeInsets.all(5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          maxLines: 2,
                                          filteredRTW![index].name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: deviceWidth * 0.04),
                                        ),
                                        Text(
                                          convertToRupiah(
                                              filteredRTW?[index].price),
                                          style: TextStyle(
                                              fontSize: deviceWidth * 0.03),
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                          ));
                    })
                : const SizedBox(
                    height: 100,
                    child: Center(
                      child: Text("Tidak ada produk Siap Pakai"),
                    ))
            : const SizedBox(
                height: 100,
                child: Center(
                  child: Text("Tidak ada produk Siap pakai"),
                )));
  }

  widgetListCustom(SearchViewModel viewmodel) {
    return Container(
        margin: const EdgeInsets.all(10),
        child: filteredCustom != null
            ? filteredCustom!.isNotEmpty
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        crossAxisCount: 2),
                    itemCount: filteredCustom?.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: accessCustom
                              ? () {
                                  goToProductScreen(filteredCustom![index]);
                                }
                              : () async {
                                },
                          child: Container(
                              width: 150,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(width: 1)),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(5),
                                          child: SvgPicture.network(
                                            filteredCustom![index]
                                                .imageUrl
                                                .first,
                                            placeholderBuilder: (BuildContext
                                                    context) =>
                                                Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey[300]!,
                                                    highlightColor:
                                                        Colors.grey[100]!,
                                                    child: Container(
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      color: Colors.grey,
                                                    )),
                                            width: 200,
                                            height: 200,
                                          ),
                                        ),
                                      ),
                                      Container(
                                          margin: const EdgeInsets.all(5),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                filteredCustom![index].name,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        deviceWidth * 0.04),
                                              ),
                                              Text(
                                                convertToRupiah(
                                                    productsCustom?[index]
                                                        .price),
                                                style: TextStyle(
                                                    fontSize:
                                                        deviceWidth * 0.03),
                                              ),
                                            ],
                                          ))
                                    ],
                                  ),
                                  accessCustom
                                      ? SizedBox()
                                      : Container(
                                          color: const Color.fromARGB(
                                              226, 255, 255, 255),
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.lock_outline_rounded),
                                              Text("Fitur ini terkunci")
                                            ],
                                          ))
                                ],
                              )));
                    })
                : const SizedBox(
                    height: 100,
                    child: Center(
                      child: Text("Tidak ada produk Custom"),
                    ))
            : const SizedBox(
                height: 100,
                child: Center(
                  child: Text("Tidak ada produk Custom"),
                )));
  }

  Future<List<String>?> getAllCategoryFromProduct(ApiService apiService) async {
    List<String> allCategories = [];
    ProductsResponse response = await apiService.productsGet();
    if (response.error) {
      Fluttertoast.showToast(
          msg: "Terjadi kesalahan, silakan coba lagi nanti.");
      return allCategories;
    } else {
      if (response.products != null) {
        Set<String> uniqueCategories = {};

        response.products!.forEach((product) {
          if (product.category != null) {
            uniqueCategories.addAll(product.category!);
          }

          allCategories = uniqueCategories.toList();
        });
      }

      return allCategories;
    }
  }

  getAllTagsFromProduct(ApiService apiService) async {
    List<String> allTags = [];
    ProductsResponse response = await apiService.productsGet();
    if (response.error) {
      Fluttertoast.showToast(
          msg: "Terjadi kesalahan, silakan coba lagi nanti.");
      return allTags;
    } else {
      if (response.products != null) {
        Set<String> uniqueTags = {};

        response.products!.forEach((product) {
          uniqueTags.addAll(product.tags);
          allTags = uniqueTags.toList();
        });
      }

      return allTags;
    }
  }

  void initializeSort() async {
    await getAllCategoryFromProduct(ApiService(context)).then((value) {
      if (value != null && !listEquals(categories, value)) {
        categories = value;
        setState(() {});
      }
    });

    await getAllTagsFromProduct(ApiService(context)).then((value) {
      if (value != null && !listEquals(tags, value)) {
        tags = value;
        setState(() {});
      }
    });
  }
}

Widget productShimmer() {
  return Padding(
      padding: EdgeInsets.all(10),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 10),
        itemCount: 10, // Jumlah item shimmer
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 150,
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 15,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 5),
                        Container(
                          width: 70,
                          height: 10,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ));
}
