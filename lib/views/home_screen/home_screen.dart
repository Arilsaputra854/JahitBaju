import 'package:flutter/material.dart';
import 'package:jahit_baju/viewmodels/home_screen_view_model.dart';
import 'package:jahit_baju/views/cart_screen/cart_screen.dart';
import 'package:jahit_baju/views/home_screen/fragment/favorite_page.dart';
import 'package:jahit_baju/views/home_screen/fragment/history_page.dart';
import 'package:jahit_baju/views/home_screen/fragment/home_page.dart';
import 'package:jahit_baju/views/home_screen/fragment/profile_page.dart';
import 'package:jahit_baju/views/home_screen/fragment/search_page.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indexPage = 0;
  late int cartItemSize;
  late HomeScreenViewModel viewModel;
  final List<Widget> page = [
    HomePage(),
    SearchPage(),
    HistoryPage(),
    FavoritePage(),
    ProfilePage()
  ];

  onItemTapped(int index) {
    setState(() {
      _indexPage = index;
    });
  }

  @override
  void initState() {
    super.initState();
    viewModel  = context.read<HomeScreenViewModel>();

    cartItemSize = 0;
  }
  

  @override
Widget build(BuildContext context) {
  //checkConnection(context);

  return Scaffold(
    appBar: AppBar(
      leading: Image.asset(
        "assets/logo/title_jahit_baju.png",
      ),
      leadingWidth: 150,
      centerTitle: false,
      backgroundColor: Colors.white,
      actions: [
        Consumer<HomeScreenViewModel>(builder: (context, vm, child) {
          print("Cart Size: ${vm.cartSize}");
          return cartIcon(vm.cartSize);
        },) 
      ],
    ),
    body: page[_indexPage],
    bottomNavigationBar: BottomNavigationBar(
      backgroundColor: Colors.white,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
      currentIndex: _indexPage,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorite"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
      ],
    ),
  );
}


  goToCartScreen() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CartScreen())).then((value){

      updateCartItemSize();
        });
  }

  Widget cartIcon(int itemCount) {
    return InkWell(
        onTap: goToCartScreen,
        child: Stack(
          children: [
            Icon(
              Icons.shopping_cart,
              size: 30, // Ukuran ikon keranjang
              color: Colors.black,
            ),
            if (itemCount > 0) // Menambahkan badge jika ada item
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.red, // Warna badge
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: Text(
                    itemCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ));
  }

  void updateCartItemSize() async {            
    await viewModel.getCartItemSize();   
  }
}
