import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jahit_baju/model/order_item.dart';
import 'package:jahit_baju/model/product.dart';
import 'package:jahit_baju/views/product_screen/product_screen.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;

    Product product = Product(
        id: 2,
        name: "Obi Mangiring Merah-Ulos",
        tags: [Tag(tag: "terlaris"), Tag(tag: "promo spesial")],
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sit amet est eget orci pulvinar volutpat. Proin et elit sit amet felis condimentum convallis. Pellentesque id purus eros. Donec pharetra suscipit velit et convallis. Fusce finibus justo semper, mattis mauris ac, semper urna. Praesent nec turpis eros. Etiam mollis in nisi non accumsan. Aliquam id neque sit amet sem commodo eleifend ut vel tellus. Donec molestie lobortis mi ac pellentesque. Vestibulum posuere condimentum ornare.",
        price: 375000,
        stock: 123,
        favorite: 2,
        seen: 24,
        sold: 5,
        type: Product.READY_TO_WEAR,
        size: ["XL", "S", "M"],
        imageUrl: [
          "https://down-id.img.susercontent.com/file/sg-11134201-22090-oj0c6ox3mxhv4e.webp",
          "https://down-id.img.susercontent.com/file/sg-11134201-22090-nzt8ypx3mxhv2d.webp",
          "https://down-id.img.susercontent.com/file/881145e16b11a838019faa3b79310e48.webp"
        ]);
    Product product1 = Product(
        id: 2,
        name: "Clutch Coat",
        tags: [Tag(tag: "terlaris"), Tag(tag: "promo spesial")],
        description:
            "Kombinasi kain ulos dan bahan polos dengan design seperti mantel berlengan panjang, berkerah half clover lapel collar, oversized body, knee lenght",
        price: 375000,
        stock: 123,
        favorite: 2,
        seen: 24,
        sold: 5,
        type: Product.CUSTOM,
        size: ["XL", "S", "M", "All Size"],
        imageUrl: [
          'https://drive.google.com/uc?export=view&id=1BMCwsRNkecJV171OdYSQ-aV5T4-sBrRf'
        ]);

    final List<String> tags = List<String>.generate(5, (i) => "Item $i");

    var productsRTW = [product];
    var productsCustom = [product1];

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
            Container(
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
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      );
                    })),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Text(
                    "Siap Pakai",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                ],
              ),
            ),
            Container(
                margin: EdgeInsets.all(10),
                height: 200,
                child: ListView.builder(
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
                                color: Colors.white,
                                border: Border.all(width: 1)),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                    })),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Text(
                    "Custom Produk",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                ],
              ),
            ),
            Container(
                margin: EdgeInsets.all(10),
                height: 250,
                child: ListView.builder(
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
                                color: Colors.white,
                                border: Border.all(width: 1)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(5),
                                    child: SvgPicture.network(
                                      productsCustom[index].imageUrl.first,
                                      placeholderBuilder:
                                          (BuildContext context) =>
                                              Container(
                                                width: 50,
                                                height: 50,
                                                child: 
                                              CircularProgressIndicator(),),
                                      width: 200,
                                      height: 200,
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
                    })),
            SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  void goToProductScreen(Product item) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProductScreen(item)));
  }
}
