import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/model/favorite.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/source/remote/response/favorite_response.dart';
import 'package:jahit_baju/data/source/remote/response/product_response.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/favorite_view_model.dart';
import 'package:jahit_baju/views/product_screen/rtw_product_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _HomePageState();
}

class _HomePageState extends State<FavoritePage> {
  var deviceWidth, deviceHeight;
  List<Favorite?> favorites = [];


  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    return Consumer<FavoriteViewModel>(builder: (context, viewModel, child) {
      return Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Favorite",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
              ),
            ),
            SizedBox(height: 5),
            FutureBuilder(
                future: viewModel.getFavorite(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return itemCartShimmer();
                  } else {
                    if (snapshot.hasData && snapshot.data !=null) {
                      favorites = snapshot.data!;
                      if (favorites.isNotEmpty) {
                        return _buildCartItem(viewModel);
                      } else {
                        return Container(
                          height: 100.h,
                          child: Center(
                            child: Text(
                              "Tidak ada produk.",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14.sp),
                            ),
                          ),
                        );
                      }
                    } else {
                      return Container(
                          height: 100.h,
                          child: Center(
                            child: Text(
                              "Tidak ada produk.",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14.sp),
                            ),
                          ),
                        );
                    }
                  }
                }),
          ],
        ));
    },);
  }

  Widget itemCartShimmer() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 1, // Jumlah item shimmer
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 15,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 100,
                      height: 12,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartItem(FavoriteViewModel viewModel) {
    return Container(
        width: deviceWidth,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Colors.white),
        child: SingleChildScrollView(child: ListView.builder(
            itemCount: favorites.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return FutureBuilder<Product?>(
                  future: viewModel.getProduct(favorites[index]!.productId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Product product = snapshot.data!;
                      return InkWell(
                          onTap: () {
                            _goToProductScreen(product);
                          },
                          child: Card(
                              color: Colors.white,
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      height: deviceWidth * 0.3,
                                      padding: const EdgeInsets.all(5),
                                      color: Colors.white,
                                      child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              bottomLeft: Radius.circular(8)),
                                          child: AspectRatio(
                                              aspectRatio: 4 / 5,
                                              child: CachedNetworkImage(
                                                      imageUrl: product
                                                          .imageUrl.first,
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (context, url) {
                                                        return Shimmer
                                                            .fromColors(
                                                                baseColor:
                                                                    Colors.grey[
                                                                        300]!,
                                                                highlightColor:
                                                                    Colors.grey[
                                                                        100]!,
                                                                child:
                                                                    Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height: double
                                                                      .infinity,
                                                                  color: Colors
                                                                      .grey,
                                                                ));
                                                      },
                                                    )))),
                                  Expanded(
                                    child: Container(
                                      color: Colors.white,
                                      margin: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name,
                                                style:  TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.sp),
                                              ),
                                              Text(
                                                convertToRupiah(product.price),
                                                style:  TextStyle(
                                                    fontSize: 12.sp),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                product.description,   
                                                maxLines: 2, // Batas jumlah baris yang ditampilkan
              overflow: TextOverflow.ellipsis,                                             
                                                style:  TextStyle(
                                                    fontSize: 12.sp),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      removeFavorite(
                                                          favorites[index]);
                                                    },
                                                    child: Icon(Icons.delete),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              )));
                    } else {
                      return Container();
                    }
                  });
            }),));
  }


  void _goToProductScreen(product) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ProductScreen(product)));
  }

  Future<void> removeFavorite(Favorite? favorite) async {
    ApiService apiService = ApiService(context);

    if (favorite != null) {
      FavoriteResponse response = await apiService.favoriteDelete(favorite.id!);
      if (response.error) {
        Fluttertoast.showToast(msg: "${response.message}");
      } else {
        setState(() {});
      }
    }else{

        Fluttertoast.showToast(msg: "Terjadi kesalahan. harap coba lagi nanti.");
    }
  }
}
