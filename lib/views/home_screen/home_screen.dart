import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    final List<String> items = List<String>.generate(20, (i) => "Item $i");

    return Scaffold(
        appBar: AppBar(
          leading: Image.asset(
            "assets/logo/title_jahit_baju.png",
          ),
          leadingWidth: 150,
          centerTitle: false,
          backgroundColor: Colors.white,
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.shopping_cart))
          ],
        ),
        body: SingleChildScrollView(
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
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 80,
                            height: 80,
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFFAAAA)),
                            child: Center(
                              child: Text(
                                items[index],
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.all(10),
                    height: 200,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Container(
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
                                    child: Image.asset(
                                      "assets/background/bg.png",
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
                                          "Blazer",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                        Text(
                                          "IDR 500.000",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ))
                              ],
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
                        "Custom Produk",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.all(10),
                    height: 200,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Container(
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
                                    child: Image.asset(
                                      "assets/background/bg.png",
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
                                          "Blazer",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                        Text(
                                          "IDR 500.000",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                          );
                        })),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ));
  }
}
