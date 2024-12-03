import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/viewmodels/home_view_model.dart';
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/views/product_screen/product_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product>? products;

  List? productsRTW;
  List? productsCustom;
  List? allProducts;

  List? tags;

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;

    return RefreshIndicator(
        child: ChangeNotifierProvider(
            create: (context) => HomeViewModel(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.black,
                    height: 300,
                    width: deviceWidth,
                    child: Image.asset(
                      alignment: const Alignment(1, -0.3),
                      "assets/background/bg.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Consumer<HomeViewModel>(builder: (context, viewModel, child) {
                    return FutureBuilder(
                        future: viewModel.getListProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                                
                              }
                          if (snapshot.hasError && viewModel.errorMsg != null) {
                            
                          }
                          // Menampilkan data atau place holder
                          List<Product>? products = snapshot.data;

                          productsRTW = products
                              ?.where((product) =>
                                  product.type == Product.READY_TO_WEAR)
                              .toList();
                          productsCustom = products
                              ?.where(
                                  (product) => product.type == Product.CUSTOM)
                              .toList();
                          allProducts = [...?productsRTW, ...?productsCustom];

                          tags = allProducts
                              ?.expand((product) => product.tags)
                              .toSet()
                              .toList();
                          return Column(
                            children: [
                              tagsWidget(),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: const Column(
                                  children: [
                                    Text(
                                      "Siap Pakai",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25),
                                    ),
                                  ],
                                ),
                              ),
                              widgetListRTW(),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: const Column(
                                  children: [
                                    Text(
                                      "Custom Produk",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25),
                                    ),
                                  ],
                                ),
                              ),
                              widgetListCustom(),
                              const SizedBox(
                                height: 40,
                              ),
                            ],
                          );
                        });
                  }),
                ],
              ),
            )),
        onRefresh: () async {
          setState(() {});
        });
  }

  void goToProductScreen(Product item) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProductScreen(item)));
  }

  tagsWidget() {
    return tags != null
        ? tags!.isNotEmpty
            ? Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tags?.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFAAAA),
                      ),
                      child: Center(
                        child: Text(
                          tags?[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    );
                  },
                ),
              )
            : Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5, // Number of placeholder items
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              )
        : Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5, // Number of placeholder items
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          );
  }

  widgetListRTW() {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 200,
      child: productsRTW != null
          ? productsRTW!.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productsRTW?.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () {
                          goToProductScreen(productsRTW?[index]);
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
                                child: SizedBox(
                                  width: double.infinity,
                                  child: CachedNetworkImage(
                                    imageUrl: productsRTW?[index].imageUrl[0],
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
                                  margin: const EdgeInsets.all(5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productsRTW?[index].name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      Text(
                                        convertToRupiah(productsRTW?[index].price),
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                        ));
                  })
              : const Center(child: Text("Tidak ada produk"))
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5, // Jumlah item shimmer
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
            ),
    );
  }

  widgetListCustom() {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 250,
      child: productsCustom != null
          ? productsCustom!.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productsCustom?.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () {
                          goToProductScreen(productsCustom?[index]);
                        },
                        child: Container(
                          width: 150,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 1)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(5),
                                  child: SvgPicture.network(
                                    productsCustom?[index].imageUrl.first,
                                    placeholderBuilder:
                                        (BuildContext context) => Container(
                                      width: 50,
                                      height: 50,
                                      child: Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
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
                                        productsCustom?[index].name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      Text(
                                        convertToRupiah(productsCustom?[index].price),
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                        ));
                  })
              : const Center(child: Text("Tidak ada produk"))
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5, // Jumlah item shimmer
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
            ),
    );
  }
  
  void showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text),
      duration: Duration(days: 365))
    );
  }
}
