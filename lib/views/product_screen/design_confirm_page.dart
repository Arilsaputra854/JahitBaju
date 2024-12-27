import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xml/xml.dart';

class DesignConfirmPage extends StatefulWidget {
  final String html;
  final String svg;

  const DesignConfirmPage(this.html, this.svg, {super.key});

  @override
  State<DesignConfirmPage> createState() => _DesignConfirmPageState();
}

class _DesignConfirmPageState extends State<DesignConfirmPage> {
  late WebViewController _controller;
  late double deviceWidth;
  late Logger log;

  @override
  void initState() {
    super.initState();
    log = Logger();
    _controller = WebViewController();
    _controller.enableZoom(false);
    _controller.loadHtmlString(widget.html);

    // Log SVG data for debugging
    log.d("SVG Content: ${widget.svg}");

    // Extract colors and log
    final extractedColors = extractColorsFromSvg(widget.svg);
    log.d("Extracted Colors: $extractedColors");
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;

    // Extract colors again for use in UI
    final colorData = extractColorsFromSvg(widget.svg);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Konfirmasi Pesanan"),
      ),
      bottomNavigationBar: Container(
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
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: (){},
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 5, // Jarak antara ikon dan teks
                          children: [
                            Icon(
                              Icons.shopping_bag,
                              color: Colors.black,
                            ),
                            Text(
                              "Tambah ke Keranjang",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap:
                                  true, // Agar teks membungkus jika tidak cukup ruang
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
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {},
                        child: Text(
                          "Beli Sekarang",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap:
                              true, // Agar teks membungkus jika terlalu panjang
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      body: Column(
        children: [
          // Display WebView
          Container(
            width: deviceWidth * 0.65,
            height: 400,
            padding: const EdgeInsets.all(10),
            child: WebViewWidget(controller: _controller),
          ),
          // Display extracted colors
          Expanded(
            child: ListView.builder(
              itemCount: colorData.length,
              itemBuilder: (context, index) {
                final id = colorData.keys.elementAt(index);
                final color = colorData[id];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color != null ? _parseColor(color) : Colors.grey,
                  ),
                  title: Text("ID: $id"),
                  subtitle: Text("Color: $color"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> extractColorsFromSvg(String svgContent) {
    final Map<String, String> colorMap = {};
  final document = XmlDocument.parse(svgContent);

  for (final path in document.findAllElements('path')) {
    final id = path.getAttribute('id');
    final fill = path.getAttribute('fill');

    if (id != null && fill != null) {
      colorMap[id] = fill;
    }
  }

  return colorMap;

  }

  Color _parseColor(String color) {
    if (color.startsWith('#')) {
      final hex = color.substring(1);
      if (hex.length == 6) {
        return Color(int.parse('0xFF$hex'));
      } else if (hex.length == 8) {
        return Color(int.parse('0x$hex'));
      }
    }
    return Colors.transparent; // Default if parsing fails
  }
  
}

