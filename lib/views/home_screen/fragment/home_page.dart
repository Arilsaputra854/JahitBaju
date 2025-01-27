import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/repository/repository.dart';
import 'package:jahit_baju/helper/app_color.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/survei_response.dart';
import 'package:jahit_baju/viewmodels/home_view_model.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/views/product_screen/product_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/source/remote/response/product_response.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product>? products = [];
  List<Product>? productsRTW = [];
  List<Product>? productsCustom = [];
  List<Product>? allProducts = [];

  List? tags;

  bool accessCustom = false;

  var deviceWidth;

  @override
  Widget build(BuildContext context) {
    loadAccessCustom(new ApiService(context)).then((value) {
      accessCustom = value;
    });

    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
          child: Stack(
            children: [
              ChangeNotifierProvider(
                  create: (context) =>
                      HomeViewModel(Repository(ApiService(context))),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        appBannerWidget(),
                        Consumer<HomeViewModel>(
                            builder: (context, viewModel, child) {
                          return FutureBuilder(
                              future: viewModel.getListProducts(),
                              builder: (context, snapshot) {
                                // Menampilkan data atau place holder
                                List<Product>? products = snapshot.data;

                                productsRTW = products
                                    ?.where((product) =>
                                        product.type == Product.READY_TO_WEAR)
                                    .toList();
                                productsCustom = products
                                    ?.where((product) =>
                                        product.type == Product.CUSTOM)
                                    .toList();
                                allProducts = [
                                  ...?productsRTW,
                                  ...?productsCustom
                                ];

                                tags = allProducts
                                    ?.expand((product) => product.tags)
                                    .toSet()
                                    .toList();
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    tagsWidget(),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Column(
                                        children: [
                                          Text("Siap Pakai",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      deviceWidth * 0.05)),
                                        ],
                                      ),
                                    ),
                                    widgetListRTW(),
                                    SizedBox(
                                      height: deviceWidth * 0.02,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Column(
                                        children: [
                                          Text(
                                            "Custom Produk",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: deviceWidth * 0.05),
                                          ),
                                        ],
                                      ),
                                    ),
                                    widgetListCustom(),
                                    SizedBox(
                                      height: deviceWidth * 0.02,
                                    ),
                                  ],
                                );
                              });
                        }),
                      ],
                    ),
                  )),
            ],
          ),
          onRefresh: () async {
            setState(() {
              products = [];
              productsRTW = [];
              productsCustom = [];
              allProducts = [];
            });
          }),
    );
  }

  void goToProductScreen(Product item) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProductScreen(item)));
  }

  tagsWidget() {
    return tags != null
        ? tags!.isNotEmpty
            ? Container(
                height: deviceWidth * 0.2,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tags?.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: deviceWidth * 0.17,
                      height: deviceWidth * 0.17,
                      margin:
                          EdgeInsets.symmetric(horizontal: deviceWidth * 0.02),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFAAAA),
                      ),
                      child: Center(
                        child: Text(
                          tags?[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              )
            : smimmerTag()
        : smimmerTag();
  }

  Widget smimmerTag() {
    return Container(
      height: deviceWidth * 0.3,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Number of placeholder items
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: deviceWidth * 0.15,
              height: deviceWidth * 0.15,
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
                    productsRTW![index];
                    return InkWell(
                        onTap: () {
                          goToProductScreen(productsRTW![index]);
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
                                  imageUrl: productsRTW![index].imageUrl[0],
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
                                        productsRTW![index].name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: deviceWidth * 0.03),
                                      ),
                                      Text(
                                        convertToRupiah(
                                            productsRTW![index].price),
                                        style: TextStyle(
                                            fontSize: deviceWidth * 0.03),
                                      ),
                                    ],
                                  )),
                              // Expanded(child: ListView.builder(
                              //     shrinkWrap: true,
                              //     itemCount: productsRTW![index].tags.length,
                              //     itemBuilder: (context, index) {
                              //       Text(
                              //         productsRTW![index].tags[index],
                              //         style: TextStyle(
                              //             fontSize: deviceWidth * 0.03),
                              //       );
                              //     }))
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
                        onTap: accessCustom
                            ? () {
                                goToProductScreen(productsCustom![index]);
                              }
                            : () async {
                                if (await checkInternetConnection()) {
                                  customSurvey(context);
                                }
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(5),
                                        child: SvgPicture.network(
                                          productsCustom![index].imageUrl.first,
                                          placeholderBuilder:
                                              (BuildContext context) =>
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
                                              productsCustom![index].name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                            Text(
                                              convertToRupiah(
                                                  productsCustom?[index].price),
                                              style:
                                                  const TextStyle(fontSize: 15),
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
        SnackBar(content: Text(text), duration: Duration(days: 365)));
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
                          const Expanded(child: Text('Tidak Pernah')),
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
                  sentSurveiData(sourceAnswer, field1Answer, field2Answer,
                          ApiService(context))
                      .then((isSuccess) {
                    if (isSuccess) {
                      Fluttertoast.showToast(msg: "Survei berhasil disimpan.");
                      Navigator.of(context).pop();
                    } else {
                      Fluttertoast.showToast(
                          msg: "Terjadi kesalahan, coba lagi.");
                    }
                  });

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

  appBannerWidget() {
    try {
      return FutureBuilder(
        future: ApiService(context).getAllAppBanner(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.appBanner != null) {
              return FlutterCarousel(
                  options: FlutterCarouselOptions(
                      viewportFraction: 1, autoPlay: true, aspectRatio: 16 / 9),
                  items: snapshot.data!.appBanner!.map((item) {
                    return CachedNetworkImage(imageUrl: item.imageUrl!);
                  }).toList());
            } else {
              return AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black,
                    width: deviceWidth,
                    child: Image.asset(
                      alignment: const Alignment(1, -0.3),
                      "assets/background/bg.png",
                      fit: BoxFit.cover,
                    ),
                  ));
            }
          } else {
            return AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black,
                  width: deviceWidth,
                  child: Image.asset(
                    alignment: const Alignment(1, -0.3),
                    "assets/background/bg.png",
                    fit: BoxFit.cover,
                  ),
                ));
          }
        },
      );
    } catch (e) {
      return AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: Colors.black,
            width: deviceWidth,
            child: Image.asset(
              alignment: const Alignment(1, -0.3),
              "assets/background/bg.png",
              fit: BoxFit.cover,
            ),
          ));
    }
  }
}
