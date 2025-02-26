import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jahit_baju/data/model/designer.dart';
import 'package:jahit_baju/data/model/look.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/designer_view_model.dart';
import 'package:jahit_baju/views/product_screen/custom_product_screen.dart';
import 'package:provider/provider.dart';

import '../product_screen/rtw_product_screen.dart';

class LookScreen extends StatefulWidget {
  final Designer designer;
  const LookScreen(this.designer, {super.key});

  @override
  State<LookScreen> createState() => _LookScreenState();
}

class _LookScreenState extends State<LookScreen> {
  late DesignerViewModel viewModel;

  @override
  void initState() {
    viewModel = context.read<DesignerViewModel>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Look", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pilih desainer favorit kamu.",
                  style: TextStyle(fontSize: 12.sp)),
              _listOfDesignerWidget()
            ],
          ),
        ));
  }

  Widget _listOfDesignerWidget() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: widget.designer.looks!.length,
      physics:
          NeverScrollableScrollPhysics(), // Agar tidak ada scroll dalam grid
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250, // Maksimum lebar per item
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1, // Agar mendekati bentuk kotak
      ),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            goToProductScreen(widget.designer.looks![index]);
          },
          child: Card(
            elevation: 4, // Tambahkan bayangan agar mirip tombol
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: IntrinsicWidth(
              child: IntrinsicHeight(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  alignment: Alignment.center,
                  child: Text(
                    widget.designer.looks![index].name,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  void goToProductScreen(Look look) {

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CustomProductScreen(widget.designer,look)));
  }
}
