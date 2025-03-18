import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jahit_baju/data/source/remote/api_service.dart';
import 'package:jahit_baju/data/model/product.dart';
import 'package:jahit_baju/data/source/remote/response/cart_response.dart';
import 'package:jahit_baju/data/source/remote/response/product_response.dart';
import 'package:jahit_baju/helper/app_color.dart';
import 'package:jahit_baju/util/util.dart';
import 'package:jahit_baju/viewmodels/product_view_model.dart';
import 'package:jahit_baju/views/cart_screen/cart_screen.dart';
import 'package:jahit_baju/views/shipping_screen/shipping_screen.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';


class ProductScreen extends StatefulWidget {
  final Product product;
  const ProductScreen(this.product, {super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  Logger log = Logger();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.product == null) {
          viewModel.setProduct(widget.product);
          viewModel.getSizeGuide();
          viewModel.getFavoriteStatus();
          viewModel.getNoteProduct(Product.READY_TO_WEAR);
        }
        return Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  "Siap Pakai",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              body: SingleChildScrollView(child: showRTW(viewModel)),
              bottomNavigationBar: _bottomNavigationWidget(viewModel),
            ),
            if (viewModel.loading) loadingWidget()
          ],
        );
      },
    );
  }

  showRTW(ProductViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          child: Container(
              color: Colors.black,
              height: 360,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: AspectRatio(
                        aspectRatio: 4 / 5,
                        child: CachedNetworkImage(
                          imageUrl: widget.product.imageUrl.first,
                          errorWidget: (context, url, error) {
                            return Icon(Icons.image_not_supported);
                          },
                          alignment: const Alignment(1, -0.3),
                          fit: BoxFit.cover,
                        )),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        '${widget.product.imageUrl.length} Foto',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          onTap: () {
            SwipeImageGallery(
              hideStatusBar: false,
              context: context,
              itemBuilder: (context, indexImage) {
                return CachedNetworkImage(
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    return Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                    );
                  },
                  imageUrl: widget.product.imageUrl[indexImage],
                );
              },
              itemCount: widget.product.imageUrl.length,
            ).show();
          },
        ),
        Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 5, // Jarak horizontal antar tag
                      runSpacing: 5, // Jarak vertikal antara baris tag
                      children: widget.product.category!.map((category) {
                        return Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Teks harga
                  Text(
                    convertToRupiah(widget.product.price),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${widget.product.sold} Terjual | ${widget.product.seen} Favorit | ${widget.product.stock} Stok \n${widget.product.seen} Orang melihat produk ini",
                    style: TextStyle(
                      fontSize: 15.sp,
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        await viewModel.addOrRemoveProductFavorite();
                      },
                      icon: IconButton(
                          onPressed: () async {
                            await viewModel.addOrRemoveProductFavorite();
                          },
                          icon: viewModel.isProductFavorited ?? false
                              ? Icon(Icons.favorite)
                              : Icon(Icons.favorite_border)))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              _materialWidget(),
              SizedBox(
                height: 20,
              ),
              _descriptionWidget(),
              SizedBox(
                height: 20,
              ),
              sizeGuideWidget(viewModel),
              SizedBox(
                height: 20,
              ),
              _careGuideWidget(viewModel),
              _noteWidget(viewModel),
              SizedBox(
                height: 10,
              ),
              _sizeWidget(viewModel),
              SizedBox(
                height: 10,
              ),
              _tagsWidget(),
            ],
          ),
        )
      ],
    );
  }

  goToCartScreen() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CartScreen()));
  }

  addToCart(ProductViewModel viewModel) async {
    ApiService apiService = ApiService(context);

    ProductResponse productResponse =
        await apiService.productsGetById(widget.product.id);
    if (productResponse.error) {
      Fluttertoast.showToast(
          msg:
              productResponse.message ?? "Terjadi kesalahan, Coba lagi nanti.");
    } else {
      if (productResponse.product != null) {
        if (productResponse.product!.stock > 0) {
          if (viewModel.selectedSize != "" && viewModel.selectedSize != null) {
            CartResponse? response = await apiService.cartAdd(
                product: widget.product,
                quantity: 1,
                selectedSize: viewModel.selectedSize!,
                customDesignSvg: null,
                look: null,
                weight: widget.product.weight!);

            if (response != null && response.error) {
              Fluttertoast.showToast(msg: response.message!);
            } else {
              Fluttertoast.showToast(
                  msg: "Berhasil menambahkan produk ke keranjang.");
            }
          } else {
            Fluttertoast.showToast(msg: "Silakan pilih ukuran terlebih dahulu");
          }
        } else {
          Fluttertoast.showToast(msg: "Maaf, Stok produk ini telah habis");
          Navigator.pop(context);
        }
      } else {
        Fluttertoast.showToast(msg: "Maaf, Produk tidak ditemukan");
      }
    }
  }

  Widget smimmerTag() {
    return Container(
      height: 360,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Number of placeholder items
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 360,
              height: 360,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }

  _sizeWidget(ProductViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          "PILIH UKURAN",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          height: 50.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.product.size.length,
            itemBuilder: (context, index) {
              final size = widget.product.size[index];
              final isSelected = viewModel.selectedSize == size;

              return GestureDetector(
                onTap: () {
                  viewModel.setSelectedSize(size);
                },
                child: Container(
                  padding: EdgeInsets.all(5),
                  width: 50.h,
                  height: 50.h,
                  margin: EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.red : Color(0xFFFFAAAA),
                    border: isSelected
                        ? Border.all(color: Colors.black, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      size,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  sizeGuideWidget(ProductViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          "PANDUAN UKURAN",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        CachedNetworkImage(
          imageUrl: viewModel.sizeGuide!,
          errorWidget: (context, url, error) {
            return Icon(Icons.image_not_supported);
          },
        )
      ],
    );
  }

  _careGuideWidget(ProductViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          "PANDUAN PERAWATAN",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          viewModel.careGuides!,
          style: TextStyle(
            fontSize: 14.sp,
          ),
        )
      ],
    );
  }

  _noteWidget(ProductViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          "CATATAN",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          viewModel.productNotes!,
          style: TextStyle(
            fontSize: 14.sp,
          ),
        )
      ],
    );
  }

  _bottomNavigationWidget(ProductViewModel viewModel) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Untuk distribusi tombol
            children: [
              // Tombol Tambah ke Keranjang
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed:
                      viewModel.loading ? null : () => addToCart(viewModel),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 5, // Jarak antara ikon dan teks
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        color: viewModel.loading
                            ? const Color.fromARGB(255, 95, 92, 92)
                            : Colors.black,
                      ),
                      Text(
                        "Tambah ke Keranjang",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: viewModel.loading
                              ? const Color.fromARGB(255, 95, 92, 92)
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
              // Tombol Beli Sekarang
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor:
                        viewModel.loading ? Colors.grey : Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    buyNow(context, viewModel.selectedSize, widget.product);
                  },
                  child: Text(
                    "Beli Sekarang",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: viewModel.loading
                          ? const Color.fromARGB(255, 95, 92, 92)
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true, // Agar teks membungkus jika terlalu panjang
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        widget.product.stock <= 0
            ? Positioned.fill(
                child: Container(
                    padding: EdgeInsets.all(20),
                    color: const Color.fromARGB(213, 255, 255, 255),
                    child: Center(
                      child: Text(
                        "Stok Habis",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp),
                      ),
                    )),
              )
            : SizedBox()
      ],
    );
  }

  _descriptionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          "DESKRIPSI",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          widget.product.description,
          style: TextStyle(
            fontSize: 14.sp,
          ),
        )
      ],
    );
  }

  _materialWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          "MATERIAL",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        if (widget.product.materials != null)
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.product.materials!.length,
            itemBuilder: (context, index) {
              return Text(
                "-${widget.product.materials![index]}",
                style: TextStyle(
                  fontSize: 14.sp,
                ),
              );
            },
          ),
      ],
    );
  }

  _tagsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          "Tags",
          style: TextStyle(
            fontSize: 16.sp,
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Wrap(
          spacing: 5, // Jarak horizontal antar tag
          runSpacing: 5, // Jarak vertikal antara baris tag
          children: widget.product.tags!.map((tag) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: AppColor.tag,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

void buyNow(BuildContext context, String? size, Product? product) {
  if (size == "" && size == null) {
    Fluttertoast.showToast(msg: "Silakan pilih ukuran terlebih dahulu.");
    return;
  }

  if (product == null) {
    Fluttertoast.showToast(msg: "Terjadi kesalahan, silakan coba lagi.");
    return;
  }

  goToShippingScreen(context, product, size!);
}

void goToShippingScreen(BuildContext context, Product? product, String size) {
  if (product != null) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShippingScreen(
                  cart: null,
                  product: product,
                  size: size,
                )));
  } else {
    Fluttertoast.showToast(
        msg: "Tidak ada produk, silakan belanja terlebih dahulu.");
  }
}
