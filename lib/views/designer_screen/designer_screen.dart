import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jahit_baju/data/model/designer.dart';
import 'package:jahit_baju/data/model/look.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/designer_view_model.dart';
import 'package:jahit_baju/views/look_screen/look_screen.dart';
import 'package:provider/provider.dart';

class DesignerScreen extends StatefulWidget {
  const DesignerScreen({super.key});

  @override
  State<DesignerScreen> createState() => _DesignerScreenState();
}

class _DesignerScreenState extends State<DesignerScreen> {
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
          title:
              Text("Desainer", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pilih desainer favorit kamu dari daftar berikut.",
                  style: TextStyle(fontSize: 12.sp)),
              _listOfDesignerWidget()
            ],
          ),
        ));
  }

  Widget _listOfDesignerWidget() {
    return FutureBuilder<List<Designer>?>(
      future: viewModel.getDesigners(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          if (snapshot.data!.isNotEmpty) {
            return GridView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    _goToLooksScreen(snapshot.data![index]);
                  },
                  child: Card(
                    elevation: 4, // Tambahkan bayangan agar mirip tombol
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IntrinsicWidth(
                      child: IntrinsicHeight(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text(
                            snapshot.data![index].name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),Text(
                            snapshot.data![index].description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                                fontSize: 12.sp,),
                          ),],
                          )
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Container(
              height: 100.h,
              child: Center(
                child: Text(
                  "Tidak ada desainer.",
                  style:
                      TextStyle(fontWeight: FontWeight.normal, fontSize: 14.sp),
                ),
              ),
            );
          }
        }

        return loadingWidget();
      },
    );
  }

  void _goToLooksScreen(Designer designer) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LookScreen(designer)));
  }
}
