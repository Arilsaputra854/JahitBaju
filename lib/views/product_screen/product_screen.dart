import 'package:flutter/material.dart';
import 'package:jahit_baju/model/order_item.dart';
import 'package:jahit_baju/model/product.dart';

class ProductScreen extends StatefulWidget {
  final OrderItem item;
  const ProductScreen( this.item, {super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.product.type == Product.READY_TO_WEAR? "Siap Pakai" : "Custom Produk"),
      ),
    );
  }
}