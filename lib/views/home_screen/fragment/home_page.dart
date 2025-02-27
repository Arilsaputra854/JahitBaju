import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/repository/repository.dart';
import 'package:jahit_baju/helper/app_color.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/survei_response.dart';
import 'package:jahit_baju/viewmodels/home_view_model.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/views/designer_screen/designer_screen.dart';
import 'package:jahit_baju/views/product_screen/rtw_product_screen.dart';
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

  List? tags;

  bool accessCustom = false;

  var deviceWidth;

  @override
  Widget build(BuildContext context) {
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
                                products = snapshot.data;

                                tags = products
                                    ?.expand((product) => product.tags)
                                    .toSet()
                                    .toList();
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    tagsWidget(),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Column(
                                        children: [
                                          Text("Siap Pakai",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp)),
                                        ],
                                      ),
                                    ),
                                    widgetListRTW(),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Column(
                                        children: [
                                          Text(
                                            "Kostum Produk",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: InkWell(
                                        onTap: accessCustom ? () {
                                          goToDesignerScreen();
                                        } : null,
                                        child: Card(
                                          color: Colors
                                              .transparent, // Biar latar belakang dari gambar terlihat
                                          child: Container(
                                            width: 360.w,
                                            height: 100.h,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                  10), // Agar tidak tajam di sudut
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    "assets/background/bg.png"),
                                                fit: BoxFit
                                                    .cover, // Menutupi seluruh area
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                // Overlay warna hitam transparan supaya teks lebih terbaca
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        115,
                                                        6,
                                                        6,
                                                        6), // Efek gelap transparan
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10), // Agar tidak tajam di sudut
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    if(!accessCustom) Container(
                                                      width: 80.w,
                                                      height: 80.w,                                                      
                                                      child: Image.asset(
                                                          "assets/icon/lock.png"),
                                                    ),
                                                    SizedBox(
                                                        width: 10
                                                            .w), // Jarak antara ikon dan teks
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text( accessCustom ? "Akses Kostumisasi": 
                                                            "Fitur Terkunci",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14.sp,
                                                              color: Colors
                                                                  .white, // Biar kontras dengan background
                                                            ),
                                                            softWrap: true,
                                                          ),
                                                          Padding(padding: EdgeInsets.only(right: 5),
                                                          child: Text(
                                                            "Buat baju kamu sendiri dengan desainer ternama.",
                                                            style: TextStyle(
                                                              fontSize: 12.sp,
                                                              color: Colors
                                                                  .white, // Supaya teks tetap terbaca
                                                            ),
                                                            softWrap: true,
                                                          ),)
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.h,
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
                height: 60.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tags?.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 60.w,
                      height: 60.w,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFAAAA),
                      ),
                      child: Center(
                        child: Text(
                          tags?[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 10.sp),
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
      margin: EdgeInsets.only(top: 20),
      height: 60.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Number of placeholder items
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 60.w,
              height: 60.w,
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
        height: 200.h,
        child: products != null
            ? products!.isNotEmpty
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products?.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            goToProductScreen(products![index]);
                          },
                          child: Container(
                            width: 150.w,
                            height: 200.h,
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
                                    imageUrl: products![index].imageUrl[0],
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
                                          products![index].name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.sp),
                                        ),
                                        Text(
                                          convertToRupiah(
                                              products![index].price),
                                          style: TextStyle(fontSize: 12.sp),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ));
                    })
                : Center(
                    child: Text(
                    "Tidak ada produk.",
                    style: TextStyle(fontSize: 12.sp),
                  ))
            : _shimmerItemWidget());
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

  _shimmerItemWidget() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5, // Jumlah item shimmer
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 150.w,
            height: 200.h,
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
                        width: 100.w,
                        height: 15.h,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 5),
                      Container(
                        width: 70.w,
                        height: 10.h,
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

  void goToDesignerScreen() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => DesignerScreen()));
  }
}
