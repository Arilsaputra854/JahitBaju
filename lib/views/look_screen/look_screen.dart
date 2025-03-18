import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/model/designer.dart';
import 'package:jahit_baju/data/model/look.dart';
import 'package:jahit_baju/data/model/look_order.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/look_view_model.dart';
import 'package:jahit_baju/views/payment_screen/payment_screen.dart';
import 'package:jahit_baju/views/product_screen/custom_product_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class LookScreen extends StatefulWidget {
  final Designer designer;
  const LookScreen(this.designer, {super.key});

  @override
  State<LookScreen> createState() => _LookScreenState();
}

class _LookScreenState extends State<LookScreen> {
  final Map<String, Future<bool>> _lookAccessFutures = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<LookViewModel>(builder: (context, viewmodel, child) {
      if (viewmodel.message != null) {
        Fluttertoast.showToast(msg: viewmodel.message!);
      }
      return Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text(widget.designer.name,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
            ),
            body: Container(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Profil Designer",
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 5,
                      ),
                      Text(widget.designer.description,
                          style: TextStyle(fontSize: 12.sp)),
                      Divider(),
                      SizedBox(
                        height: 5,
                      ),
                      Text("Pilih Look",
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      _listOfDesignerWidget(viewmodel)
                    ],
                  ),
                )),
          ),
          if (viewmodel.loading) loadingWidget(),
        ],
      );
    });
  }

  Widget _listOfDesignerWidget(LookViewModel viewmodel) {
    if (widget.designer.looks != null && widget.designer.looks!.isNotEmpty) {
      // Sort list berdasarkan nama
      List<Look> sortedLooks = List.from(widget.designer.looks!)
        ..sort((a, b) => _compareLookNames(a.name, b.name));

      return GridView.builder(
        shrinkWrap: true,
        itemCount: sortedLooks.length,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          String lookId = sortedLooks[index].id;
          _lookAccessFutures[lookId] ??= viewmodel.getLookAccess(lookId);

          return FutureBuilder(
            future: _lookAccessFutures[lookId],
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return InkWell(
                  onTap: () async {
                    if (snapshot.data!) {
                      goToProductScreen(sortedLooks[index]);
                    } else {
                      dialogBuyLook(sortedLooks[index], viewmodel);
                    }
                  },
                  child: _buildLookCard(sortedLooks[index], snapshot.data!),
                );
              }
              return lookShimmer();
            },
          );
        },
      );
    } else {
      return _emptyLookWidget();
    }
  }

  int _compareLookNames(String a, String b) {
    RegExp regExp = RegExp(r'(\d+)');
    Match? matchA = regExp.firstMatch(a);
    Match? matchB = regExp.firstMatch(b);

    if (matchA != null && matchB != null) {
      return int.parse(matchA.group(0)!).compareTo(int.parse(matchB.group(0)!));
    }
    return a.compareTo(b);
  }

  Widget lookShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 150,
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
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
  }

  Widget _buildLookCard(Look look, bool isAccessible) {
    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: SvgPicture.network(
                look.designUrl, // Ganti dengan URL SVG
                fit: BoxFit.cover,
              ),
            ),

            // 🔹 Overlay Gelap Transparan
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(199, 6, 6, 6),
                ),
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!isAccessible)
                  Container(
                    width: 60.w,
                    height: 60.w,
                    child: Image.asset("assets/icon/lock.png"),
                  ),
                Text(
                  look.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  convertToRupiah(look.lookPrice),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),);
  }

  Widget _emptyLookWidget() {
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

  void goToProductScreen(Look look) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CustomProductScreen(widget.designer, look)));
  }

  void goToPaymentScreen(LookOrder lookOrder) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaymentScreen(
                  lookOrder: lookOrder,
                )));
  }

  void dialogBuyLook(Look look, LookViewModel viewmodel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pembelian Look'),
          content: Text(
              'Kamu dapat kostumisasi look ini dengan membayar ${convertToRupiah(look.lookPrice)}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                LookOrder? lookOrder = await viewmodel.buyLook(look.id);
                if (lookOrder != null) {
                  goToPaymentScreen(lookOrder);
                }
              },
              child: Text('Beli'),
            ),
          ],
        );
      },
    );
  }
}
