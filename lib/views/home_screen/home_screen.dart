import 'package:flutter/material.dart';
import 'package:jahit_baju/views/home_screen/fragment/history_page.dart';
import 'package:jahit_baju/views/home_screen/fragment/home_page.dart';
import 'package:jahit_baju/views/home_screen/fragment/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _indexPage = 0;

  final List<Widget> page =[
    HomePage(),
    HistoryPage(),
    ProfilePage()
  ];

  onItemTapped(int index){
    setState(() {
      _indexPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {

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
        body: page[_indexPage],
        bottomNavigationBar: BottomNavigationBar(
          onTap: onItemTapped,
          currentIndex: _indexPage,
          items: [
          BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
        ]));
  }
}



