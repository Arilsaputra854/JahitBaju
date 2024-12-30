

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jahit_baju/helper/app_color.dart';
import 'package:jahit_baju/helper/preferences.dart';
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/search_view_model.dart';
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

  var deviceWidth;

  @override
  void initState() {
    loadAccessCustom().then((value) {
      if (value == null) {
        accessCustom = false;
      } else {
        accessCustom = value!;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
        create: (context) => SearchViewModel(),
        child: Scaffold(
          appBar: AppBar(
            title: Row(
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
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Jarak antara TextField dan Icon

                Material(
                  shape: CircleBorder(side: BorderSide(width: 1)),
                  child: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      searchProduct(searchController.text);
                    },
                  ),
                )
              ],
            ),
            backgroundColor: Colors.white,
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

                    if (filteredRTW == null)
                      filteredRTW = List.from(productsRTW!);
                    if (filteredCustom == null)
                      filteredCustom = List.from(productsCustom!);

                    return SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Center(child: Text(
                                      "Siap Pakai",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: deviceWidth * 0.04)
                                    ),)
                              ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: widgetListRTW(),
                        ),
                        Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Center(child: Text(
                                      "Custom Produk",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: deviceWidth * 0.04)
                                    ),)
                              ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: widgetListCustom(),
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
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemCount: filteredRTW?.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            goToProductScreen(filteredRTW![index]);
                          },
                          child: Container(
                            width: 150,
                            height: 200,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
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
                                )),
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
                                              fontSize: deviceWidth * 0.03),
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
                : const SizedBox(height: 100,child: Center(child: Text("Tidak ada produk Ready to wear"),))
            : const SizedBox(height: 100,child: Center(child: Text("Tidak ada produk Ready to wear"),)));
  }

  widgetListCustom() {
    return Container(
        margin: const EdgeInsets.all(10),
        child: filteredCustom != null
            ? filteredCustom!.isNotEmpty
                ? GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemCount: filteredCustom?.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: accessCustom
                              ? () {
                                  goToProductScreen(filteredCustom![index]);
                                }
                              : () {
                                  customSurvey(context);
                                },
                          child: Container(
                              width: 150,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
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
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                              Text(
                                                convertToRupiah(
                                                    productsCustom?[index]
                                                        .price),
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              ),
                                            ],
                                          ))
                                    ],
                                  ),
                                  accessCustom
                                      ? SizedBox()
                                      : Center(
                                          child: Icon(
                                            Icons.lock,
                                            color: AppColor.primary,
                                            size: 100,
                                          ),
                                        ),
                                ],
                              )));
                    })
              
                : const SizedBox(height: 100,child: Center(child: Text("Tidak ada produk Custom"),))
            : const SizedBox(height: 100,child: Center(child: Text("Tidak ada produk Custom"),)));
  }

  void customSurvey(BuildContext context) {
    String field1Answer = '';
    String field2Answer = '';
    String sourceAnswer = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Survei Aplikasi'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Apakah kamu tahu kain ulos?'),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Ya',
                            groupValue: field1Answer,
                            onChanged: (value) {
                              setState(() {
                                field1Answer = value!;
                              });
                            },
                          ),
                          const Text('Ya'),
                          Radio<String>(
                            value: 'Tidak',
                            groupValue: field1Answer,
                            onChanged: (value) {
                              setState(() {
                                field1Answer = value!;
                              });
                            },
                          ),
                          const Text('Tidak'),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                          'Apakah pernah membeli atau memiliki kain ulos?'),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Pernah',
                            groupValue: field2Answer,
                            onChanged: (value) {
                              setState(() {
                                field2Answer = value!;
                              });
                            },
                          ),
                          const Text('Pernah'),
                          Radio<String>(
                            value: 'Tidak Pernah',
                            groupValue: field2Answer,
                            onChanged: (value) {
                              setState(() {
                                field2Answer = value!;
                              });
                            },
                          ),
                          const Text('Tidak Pernah'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Darimana kamu tahu JahitBaju?'),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Teman',
                        groupValue: sourceAnswer,
                        onChanged: (value) {
                          setState(() {
                            sourceAnswer = value!;
                          });
                        },
                      ),
                      const Text('Teman'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Sosial Media',
                        groupValue: sourceAnswer,
                        onChanged: (value) {
                          setState(() {
                            sourceAnswer = value!;
                          });
                        },
                      ),
                      const Text('Sosial Media'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Website',
                        groupValue: sourceAnswer,
                        onChanged: (value) {
                          setState(() {
                            sourceAnswer = value!;
                          });
                        },
                      ),
                      const Text('Website'),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (sourceAnswer != "" &&
                    field1Answer != "" &&
                    field2Answer != "") {
                  saveAccessCustom(true)
                      .then((value) => Navigator.of(context).pop());
                  setState(() {});
                }
              },
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );
  }
}
Widget productShimmer(){
  return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,mainAxisSpacing: 10),
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
            );
}