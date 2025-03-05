import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/model/designer.dart';
import 'package:jahit_baju/data/model/look.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/designer_view_model.dart';
import 'package:jahit_baju/viewmodels/look_view_model.dart';
import 'package:jahit_baju/views/product_screen/custom_product_screen.dart';
import 'package:provider/provider.dart';

class LookScreen extends StatefulWidget {
  final Designer designer;
  const LookScreen(this.designer, {super.key});

  @override
  State<LookScreen> createState() => _LookScreenState();
}

class _LookScreenState extends State<LookScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LookViewModel>(builder: (context, viewmodel, child) {
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
                Text("Pilih look dari desainer pilihan kamu.",
                    style: TextStyle(fontSize: 12.sp)),
                _listOfDesignerWidget(viewmodel)
              ],
            ),
          ));
    });
  }

  Widget _listOfDesignerWidget(LookViewModel viewmodel) {
    if (widget.designer.looks != null) {
      if (widget.designer.looks!.isNotEmpty) {
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
            return FutureBuilder(
              future: viewmodel.getLookAccess(widget.designer.looks![index].id),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return InkWell(
                    onTap: () async {
                      if (snapshot.data!) {
                        goToProductScreen(widget.designer.looks![index]);
                      } else {
                        buyLook(widget.designer.looks![index].id);
                      }
                    },
                    child: Card(
                      elevation: 4, // Tambahkan bayangan agar mirip tombol
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IntrinsicWidth(
                        child: IntrinsicHeight(
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    10), // Agar tidak tajam di sudut
                                image: DecorationImage(
                                  image: AssetImage("assets/background/bg.png"),
                                  fit: BoxFit.cover, // Menutupi seluruh area
                                ),
                              ),
                              child: Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: [
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(115, 6, 6,
                                              6), // Efek gelap transparan
                                          borderRadius: BorderRadius.circular(
                                              10), // Agar tidak tajam di sudut
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if(!snapshot.data!)
                                        Container(
                                          width: 60.w,
                                          height: 60.w,
                                          child: Image.asset(
                                              "assets/icon/lock.png"),
                                        ),
                                        Text(
                                          widget.designer.looks![index].name,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          convertToRupiah(widget.designer
                                              .looks![index].lookPrice),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  ])),
                        ),
                      ),
                    ),
                  );
                }
                return itemCartShimmer();
              },
            );
          },
        );
      } else {
        return Container(
          height: 100.h,
          child: Center(
            child: Text(
              "Tidak ada look.",
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14.sp),
            ),
          ),
        );
      }
    } else {
      return Container(
        height: 100.h,
        child: Center(
          child: Text(
            "Tidak ada look.",
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14.sp),
          ),
        ),
      );
    }
  }

  void goToProductScreen(Look look) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CustomProductScreen(widget.designer, look)));
  }

  void buyLook(String id) {
    Fluttertoast.showToast(msg: "buy look ${id}");
  }
}
