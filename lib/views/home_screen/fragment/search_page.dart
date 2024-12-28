import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/search_view_model.dart';
import 'package:jahit_baju/views/product_screen/product_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  var searchController = TextEditingController();

  List? productsRTW;
  List? productsCustom;


  var deviceWidth;

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(create: (context) => SearchViewModel(),child: Scaffold(
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
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
              ),
            ),
            const SizedBox(width: 8), // Jarak antara TextField dan Icon
            
            Material(
              shape: CircleBorder(
                side: BorderSide(width: 1)
              ),
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
      body: Consumer<SearchViewModel>(builder: (context, viewModel, child) {
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

                          return SingleChildScrollView(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child:  
                              widgetListRTW(),
                              )
                            ],
                          ));
                        });
                  }),
    ));
  }
  
  void searchProduct(String text) {
  }


  void goToProductScreen(Product item) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProductScreen(item)));
  }
  widgetListRTW() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: productsRTW != null
          ? productsRTW!.isNotEmpty
              ? GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
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
                                child: Center(
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
                                )
                              ),
                              Container(
                                  margin: EdgeInsets.all(5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        maxLines: 2,
                                        productsRTW?[index].name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: deviceWidth*0.03),
                                      ),
                                      Text(
                                        convertToRupiah(productsRTW?[index].price),
                                        style: TextStyle(fontSize: deviceWidth*0.03),
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                        ));
                  })
              : const Center(child: Text("Tidak ada produk"))
          : GridView.builder(
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
            ),
    );
  }

}
