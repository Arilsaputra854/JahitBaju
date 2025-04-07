import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/helper/app_color.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/search_view_model.dart';
import 'package:jahit_baju/views/product_screen/rtw_product_screen.dart';
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

  Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SearchViewModel>(context, listen: false).getListProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () {
      FocusScope.of(context).unfocus();
    }, child: Consumer<SearchViewModel>(builder: (context, viewModel, child) {
      initializeSort(viewModel);

      return Scaffold(
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
                              onChanged: (value) {
                                viewModel.setSearchQuery(value);
                                searchProduct(value, viewModel);
                              },
                              style: TextStyle(fontSize: 14.sp),
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
                          const SizedBox(width: 8),

                          Material(
                            shape: CircleBorder(side: BorderSide(width: 1)),
                            child: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                viewModel.setSearchQuery(searchController.text);

                                searchProduct(
                                    viewModel.searchQuery ?? "", viewModel);
                              },
                            ),
                          )
                        ],
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            children: [
                              DropdownButton<String>(
                                hint: Text("Kategori",
                                    style: TextStyle(fontSize: 12.sp)),
                                value: viewModel.selectedCategory?.isNotEmpty ==
                                        true
                                    ? viewModel.selectedCategory
                                    : null,
                                items: viewModel.categories.map((value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value,
                                        style: TextStyle(fontSize: 12.sp)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  Fluttertoast.showToast(
                                      msg:
                                          "Produk di urutkan berdasarkan ${value}");
                                  if (value != null) {
                                    viewModel.setSelectedCategory(value);

                                    viewModel.setFilteredRTW(
                                        viewModel.productsRTW!.where((product) {
                                      if (product.category != null &&
                                          product.category!.isNotEmpty) {
                                        return product.category!.any(
                                            (category) => category == value);
                                      }
                                      return false;
                                    }).toList());
                                  }
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              DropdownButton(
                                hint: Text(
                                  "Tag",
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                                value: viewModel.selectedTags == null
                                    ? null
                                    : viewModel.selectedTags,
                                items: viewModel.tags.map((value) {
                                  return DropdownMenuItem(
                                    child: Text(value,
                                        style: TextStyle(fontSize: 12.sp)),
                                    value: value,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  Fluttertoast.showToast(
                                      msg:
                                          "Produk di urutkan berdasarkan ${value}");
                                  if (value != null) {
                                    viewModel.setSelectedTags(value);
                                    if (viewModel.selectedTags != null &&
                                        viewModel.selectedTags!.isNotEmpty) {
                                      viewModel.setFilteredRTW(viewModel
                                          .productsRTW!
                                          .where((product) => product.tags.any(
                                              (tag) => viewModel.selectedTags!
                                                  .contains(tag)))
                                          .toList());
                                    }
                                  }
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              viewModel.selectedCategory != null ||
                                      viewModel.selectedTags != null
                                  ? InkWell(
                                      onTap: () {
                                        viewModel.setSelectedCategory(null);
                                        viewModel.setSelectedTags(null);
                                        viewModel.setFilteredRTW(
                                            List.from(viewModel.productsRTW!));
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
          body: RefreshIndicator(
              onRefresh: () async {
                await viewModel.refresh();
              },
              child: productWidget(viewModel)));
    }));
  }

  void searchProduct(String text, SearchViewModel viewModel) {
    filterProducts(text, viewModel);
  }

  void filterProducts(String query, SearchViewModel viewModel) {
    if (viewModel.productsRTW != null) {
      viewModel.setFilteredRTW(viewModel.productsRTW!
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList());
    }
  }

  void goToProductScreen(Product item) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProductScreen(item)));
  }

  Widget widgetListRTW(SearchViewModel viewModel) {
    List<Product>? products = viewModel.filteredRTW ?? viewModel.productsRTW;

    if (products == null || products.isEmpty) {
      return SizedBox(
        height: 100.h,
        child: Center(
          child: Text(
            "Tidak ada produk.",
            style: TextStyle(fontSize: 12.sp),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(10),
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 0.7,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              crossAxisCount: 2),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return InkWell(
                onTap: () {
                  goToProductScreen(products[index]);
                },
                child: buildProductCard(products[index]));
          }),
    );
  }

  Widget buildProductCard(Product product) {
    return Container(
      decoration:
          BoxDecoration(color: Colors.white, border: Border.all(width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: product.imageUrl[0],
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                ),
                Text(
                  convertToRupiah(product.price),
                  style: TextStyle(fontSize: 12.sp),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void initializeSort(SearchViewModel viewModel) {
    if (viewModel.productsRTW == null || viewModel.productsRTW!.isEmpty) {
      return;
    }

    List<String> newCategories = viewModel.productsRTW!
        .where((product) => product.category != null)
        .expand((product) => product.category!)
        .toSet()
        .toList();

    List<String> newTags = viewModel.productsRTW!
        .expand((product) => product.tags)
        .toSet()
        .toList();

    if (!listEquals(viewModel.categories, newCategories)) {
      viewModel.setCategories(newCategories);
    }

    if (!listEquals(viewModel.tags, newTags)) {
      viewModel.setTags(newTags);
    }
  }

  productWidget(SearchViewModel viewModel) {
    if (viewModel.selectedCategory != null &&
        viewModel.selectedCategory!.isNotEmpty) {
      Future.delayed(Duration.zero, () {
        viewModel.setFilteredRTW(viewModel.productsRTW!.where((product) {
          if (product.category != null && product.category!.isNotEmpty) {
            return product.category!.any(
                (category) => viewModel.selectedCategory!.contains(category));
          } else {
            return false;
          }
        }).toList());
      });
    }

    if (viewModel.filteredRTW == null) {
      viewModel.setFilteredRTW(List.from(viewModel.productsRTW!));
    }

    if ((viewModel.selectedCategory == null &&
            viewModel.selectedTags == null) &&
        viewModel.searchQuery == null) {
      Future.delayed(Duration.zero, () {
        viewModel.setFilteredRTW(List.from(viewModel.productsRTW!));
      });
    }
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: widgetListRTW(viewModel),
        ),
      ],
    ));
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
