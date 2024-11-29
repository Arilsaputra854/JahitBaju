import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  var searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: const Center(
        child: Text("Search Page Body"),
      ),
    );
  }
  
  void searchProduct(String text) {
    print(text);
  }
}
