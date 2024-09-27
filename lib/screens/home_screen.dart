import 'package:flutter/material.dart';
import 'package:ornek_proje/screens/user.dart';
import 'package:ornek_proje/screens/update.dart';
import 'package:pdf/pdf.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:cross_file/cross_file.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

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
                                        _exportPdf(filteredPdfItems[index]);
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
    String correctedUrl = pdfItem.url.replaceAll(
        'https://drive.google.com/uc?export=download&id=',
        'https://drive.google.com/file/d/');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 320,
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
                        data: correctedUrl,
                        version: QrVersions.auto,
                        size: 100.0,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
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
                    onPressed: () => _shareQrCode(correctedUrl),
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

        final result = await ImageGallerySaver.saveImage(
          buffer,
          quality: 100,
          name: "${fileName}_qr.png",
        );

        if (result['isSuccess']) {
          Navigator.pop(context); // Önce modal bottom sheet'i kapat
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('QR kodu başarıyla galeriye kaydedildi!'),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Color.fromARGB(255, 7, 44, 62),
              elevation: 6,
            ),
          );
        } else {
          throw Exception('QR kodu kaydedilemedi');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Depolama izni verilmedi!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
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

  Future<bool> _requestStoragePermission() async {
    if (await Permission.storage.isGranted) {
      return true;
    } else {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<void> _exportPdf(PdfItem pdfItem) async {
    if (!await _requestStoragePermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Depolama izni verilmedi. Dosya kaydedilemez.')),
      );
      return;
    }

    try {
      // URL'den dosyayı indir
      final response = await http.get(Uri.parse(pdfItem.url));
      if (response.statusCode != 200) {
        throw Exception('Dosya indirilemedi');
      }

      // Geçici dosya oluştur
      final tempDir = await getTemporaryDirectory();
      File tempFile = File('${tempDir.path}/${pdfItem.name}');
      await tempFile.writeAsBytes(response.bodyBytes);

      // Dosyayı paylaş
      final xFile = XFile(tempFile.path);
      final result = await Share.shareXFiles([xFile], text: 'PDF Dosyası');

      // Geçici dosyayı sil
      await tempFile.delete();

      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF başarıyla paylaşıldı')),
        );
      } else {
        throw Exception('Dosya paylaşılamadı');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dışa aktarma sırasında bir hata oluştu: $e')),
      );
    }
  }
}
