import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jahit_baju/api/api_service.dart';
import 'package:jahit_baju/helper/secure/token_storage.dart';
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/views/product_screen/product_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = [];

  List productsRTW = [];
  List productsCustom = [];
  List allProducts = [];

  List tags = [];

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;

    ApiService apiService = ApiService();

    return RefreshIndicator(
        child: FutureBuilder(
            future: apiService.productsGet(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text("Terjadi Kesalahan: ${snapshot.error}"));
              } else {
                if (snapshot.data is String) {
                  return Center(
                      child: Text("Terjadi Kesalahan: ${snapshot.data}"));
                } else if (snapshot.data is List<Product>) {
                  // Menampilkan data jika sudah tersedia
                  List<Product> products = snapshot.data!;

                  productsRTW = products
                      .where((product) => product.type == Product.READY_TO_WEAR)
                      .toList();
                  productsCustom = products
                      .where((product) => product.type == Product.CUSTOM)
                      .toList();
                  allProducts = [...productsRTW, ...productsCustom];

                  tags = allProducts
                      .expand((product) => product.tags)
                      .toSet()
                      .toList();

                  return SingleChildScrollView(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: Colors.black,
                            height: 300,
                            width: deviceWidth,
                            child: Image.asset(
                              alignment: Alignment(1, -0.3),
                              "assets/background/bg.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                          tagsWidget(),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                Text(
                                  "Siap Pakai",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30),
                                ),
                              ],
                            ),
                          ),
                          widgetListRTW(),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                Text(
                                  "Custom Produk",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30),
                                ),
                              ],
                            ),
                          ),
                          widgetListCustom(),
                          SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Center(child: Text("Terjadi kesalahan"));
                }
              }
            }),
        onRefresh: () async{
          setState(() {
            
          });
        });
  }

  void goToProductScreen(Product item) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProductScreen(item)));
  }

  tagsWidget() {
    return products.isNotEmpty
        ? Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            height: 100,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 80,
                    height: 80,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xFFFFAAAA)),
                    child: Center(
                      child: Text(
                        tags[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  );
                }))
        : Container();
  }

  widgetListRTW() {
    return Container(
        margin: EdgeInsets.all(10),
        height: 200,
        child: productsRTW.isNotEmpty
            ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productsRTW.length,
                itemBuilder: (context, index) {
                  return InkWell(
                      onTap: () {
                        goToProductScreen(productsRTW[index]);
                      },
                      child: Container(
                        width: 150,
                        height: 200,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            color: Colors.white, border: Border.all(width: 1)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                child: Image.network(
                                  productsRTW[index].imageUrl[0],
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
                                      productsRTW[index].name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    Text(
                                      "IDR ${productsRTW[index].price}",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ))
                          ],
                        ),
                      ));
                })
            : Center(child: Text("Tidak ada produk")));
  }

  widgetListCustom() {
    return Container(
        margin: EdgeInsets.all(10),
        height: 250,
        child: productsCustom.isNotEmpty
            ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productsCustom.length,
                itemBuilder: (context, index) {
                  return InkWell(
                      onTap: () {
                        goToProductScreen(productsCustom[index]);
                      },
                      child: Container(
                        width: 150,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            color: Colors.white, border: Border.all(width: 1)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(5),
                                child: SvgPicture.network(
                                  productsCustom[index].imageUrl.first,
                                  placeholderBuilder: (BuildContext context) =>
                                      Container(
                                    width: 50,
                                    height: 50,
                                    child: CircularProgressIndicator(),
                                  ),
                                  width: 200,
                                  height: 200,
                                ),
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.all(5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productsCustom[index].name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    Text(
                                      "IDR ${productsCustom[index].price}",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ))
                          ],
                        ),
                      ));
                })
            : Center(child: Text("Tidak ada produk")));
  }
}
