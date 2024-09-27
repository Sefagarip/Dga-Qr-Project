import 'package:flutter/material.dart';
import 'package:ornek_proje/screens/user.dart';
import 'package:ornek_proje/screens/update.dart';
import 'package:pdf/pdf.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final FocusNode _focusNode = FocusNode();
  List<PdfItem> pdfItems = [];
  List<PdfItem> filteredPdfItems = [];
  int? expandedIndex;
  final GlobalKey _qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    filteredPdfItems = pdfItems;
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _isSearching = false;
          filteredPdfItems = pdfItems;
        });
      }
    });
  }

  void _filterPdfItems(String query) {
    setState(() {
      filteredPdfItems = pdfItems
          .where(
              (item) => item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF041a25),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: Color(0xFF041a25),
          title: _isSearching
              ? GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(_focusNode);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: Color(0xFFFFCC00),
                          child: TextField(
                            autofocus: true,
                            focusNode: _focusNode,
                            style: TextStyle(
                              color: Color(0xFF041a25),
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              hintText: '🔍',
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                            ),
                            onChanged: _filterPdfItems,
                          ),
                        ),
                      ),
                      Container(
                        color: Color(0xFFFFCC00),
                        child: IconButton(
                          icon: Icon(Icons.close, color: Color(0xFF041a25)),
                          onPressed: () {
                            setState(() {
                              _isSearching = false;
                              filteredPdfItems = pdfItems;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Projeler',
                      style: TextStyle(
                        color: Color(0xFFFFCC00),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFCC00),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.search, color: Color(0xFF041a25)),
                        onPressed: () {
                          setState(() {
                            _isSearching = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (_isSearching) {
            FocusScope.of(context).unfocus();
          }
        },
        child: Container(
          color: Colors.transparent,
          child: filteredPdfItems.isEmpty
              ? Center(
                  child: Text(
                    'Henüz PDF yüklenmedi veya arama sonucu bulunamadı',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredPdfItems.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFCC00),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                filteredPdfItems[index].name,
                                style: TextStyle(color: Color(0xFF041a25)),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  expandedIndex == index
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  color: Color(0xFF041a25),
                                ),
                                onPressed: () {
                                  setState(() {
                                    expandedIndex =
                                        expandedIndex == index ? null : index;
                                  });
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  expandedIndex =
                                      expandedIndex == index ? null : index;
                                });
                              },
                            ),
                            if (expandedIndex == index)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildActionButton(
                                      icon: Icons.qr_code,
                                      label: 'QR Göster',
                                      onPressed: () {
                                        _showQRCode(
                                            context, filteredPdfItems[index]);
                                      },
                                    ),
                                    _buildActionButton(
                                      icon: Icons.file_upload,
                                      label: 'Dışa Aktar',
                                      onPressed: () {
                                        // Dışa aktarma işlevi buraya eklenecek
                                      },
                                    ),
                                    _buildActionButton(
                                      icon: Icons.visibility,
                                      label: 'Göster',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PdfPreviewScreen(
                                              pdfUrl:
                                                  filteredPdfItems[index].url,
                                              initialPdfName:
                                                  filteredPdfItems[index].name,
                                              isViewOnly: true,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildActionButton(
                                      icon: Icons.delete,
                                      label: 'Sil',
                                      onPressed: () {
                                        setState(() {
                                          pdfItems.removeAt(index);
                                          expandedIndex = null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 62,
        child: BottomAppBar(
          color: Color.fromARGB(255, 7, 44, 62),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25.0)),
                    ),
                    builder: (BuildContext context) {
                      return UpdateMenu();
                    },
                  ).then((result) {
                    if (result != null && result is PdfItem) {
                      setState(() {
                        pdfItems.add(result);
                      });
                    }
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload,
                        color: Color(0xFFFFCC00), size: 24),
                    Text(
                      'Yükle',
                      style: TextStyle(color: Color(0xFFFFCC00), fontSize: 10),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25.0)),
                    ),
                    builder: (BuildContext context) {
                      return UserMenu();
                    },
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, color: Color(0xFFFFCC00), size: 24),
                    Text(
                      'Kullanıcı',
                      style: TextStyle(color: Color(0xFFFFCC00), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQRCode(BuildContext context, PdfItem pdfItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 320, // Yüksekliği biraz artırdık
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF041a25),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),
                  Text(
                    '       QR Göster',
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFFFFCC00),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Color(0xFFFFCC00)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: RepaintBoundary(
                    key: _qrKey,
                    child: Container(
                      color: Colors.white,
                      child: QrImageView(
                        data: pdfItem.url,
                        version: QrVersions.auto,
                        size: 100.0,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                  height: 20), // QR kod ile butonlar arasına boşluk ekledik
              Column(
                children: [
                  _buildQRActionButton(
                    icon: Icons.save,
                    label: 'Kaydet',
                    onPressed: () => _saveQrCode(context, pdfItem.name),
                    isFirst: true,
                  ),
                  SizedBox(height: 1),
                  _buildQRActionButton(
                    icon: Icons.share,
                    label: 'Paylaş',
                    onPressed: () => _shareQrCode(pdfItem.url),
                  ),
                  SizedBox(height: 1),
                  _buildQRActionButton(
                    icon: Icons.print,
                    label: 'Yazdır',
                    onPressed: _printQrCode,
                    isLast: true,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveQrCode(BuildContext context, String fileName) async {
    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        final RenderRepaintBoundary boundary =
            _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        final ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        final Uint8List buffer = byteData!.buffer.asUint8List();

        final result =
            await ImageGallerySaver.saveImage(buffer, name: '${fileName}_qr');
        if (result['isSuccess']) {
          // SnackBar'ı ön plana getirmek için Navigator.pop'tan sonra gösteriyoruz
          Navigator.of(context).pop(); // Modal bottom sheet'i kapat
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR kodu galeriye kaydedildi!'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          throw 'Kaydetme başarısız oldu';
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Galeriye kaydetme izni verilmedi!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  Future<void> _printQrCode() async {
    try {
      final RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final pw.Document doc = pw.Document();
          doc.addPage(
            pw.Page(
              build: (context) {
                return pw.Center(
                  child: pw.Image(pw.MemoryImage(pngBytes)),
                );
              },
            ),
          );
          return doc.save();
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yazdırma hatası: $e')),
      );
    }
  }

  void _shareQrCode(String url) {
    Share.share('PDF Linki: $url', subject: 'QR Kod Paylaşımı');
  }

  Widget _buildQRActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Color(0xFFFFCC00),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? Radius.circular(10) : Radius.zero,
          bottom: isLast ? Radius.circular(10) : Radius.zero,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Color(0xFF041a25), size: 20),
                SizedBox(width: 8),
                Text(label,
                    style: TextStyle(color: Color(0xFF041a25), fontSize: 14)),
              ],
            ),
            Icon(Icons.chevron_right, color: Color(0xFF041a25), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Color(0xFF041a25)),
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Color(0xFF041a25)),
        ),
      ],
    );
  }
}
