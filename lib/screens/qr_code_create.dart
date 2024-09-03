import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:pdf/pdf.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class QrCodeCreate extends StatefulWidget {
  const QrCodeCreate({super.key});

  @override
  _QrCodeCreateState createState() => _QrCodeCreateState();
}

class _QrCodeCreateState extends State<QrCodeCreate> {
  final TextEditingController _controller = TextEditingController();
  String _qrData = "";
  final GlobalKey _qrKey = GlobalKey();
  bool _isPreviewShown = false;
  bool _isQrGenerated = false;

  Future<void> _saveQrCode() async {
    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        final RenderRepaintBoundary boundary =
            _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        final ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        final Uint8List buffer = byteData!.buffer.asUint8List();

        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/qrcode.png';
        final file = File(path);
        await file.writeAsBytes(buffer);

        final result = await ImageGallerySaver.saveFile(file.path);
        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR kodu galeriye kaydedildi!')),
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
          final pdf.Document doc = pdf.Document();
          doc.addPage(
            pdf.Page(
              build: (context) {
                return pdf.Center(
                  child: pdf.Image(pdf.MemoryImage(pngBytes)),
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

  void _previewPdf() {
    if (_isValidDriveLink(_qrData)) {
      final formattedUrl = _formatDriveLink(_qrData);
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => PdfPreviewScreen(pdfUrl: formattedUrl),
        ),
      )
          .then((_) {
        // PDF önizleme gösterildikten sonra QR kod oluştur butonu aktif olacak
        setState(() {
          _isPreviewShown = true;
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçersiz Google Drive PDF linki!')),
      );
    }
  }

  bool _isValidDriveLink(String url) {
    return url.contains('drive.google.com/file/d/') ||
        url.contains('drive.google.com/open?id=');
  }

  String _formatDriveLink(String url) {
    String fileId;
    if (url.contains('drive.google.com/file/d/')) {
      fileId = url.split('/d/')[1].split('/')[0];
    } else if (url.contains('drive.google.com/open?id=')) {
      fileId = url.split('id=')[1];
    } else {
      return url;
    }
    return 'https://drive.google.com/uc?export=view&id=$fileId';
  }

  void _updateQrData() {
    setState(() {
      _qrData = _controller.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLinkValid = _isValidDriveLink(_qrData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Kod Oluşturma'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Linki Girin',
                hintText: 'https://drive.google.com/...',
              ),
              onChanged: (text) {
                _updateQrData();
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLinkValid ? _previewPdf : null,
              child: const Text('PDF Önizleme Göster'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isPreviewShown
                  ? () {
                      setState(() {
                        _isQrGenerated = true;
                      });
                    }
                  : null,
              child: const Text('QR Kodu Oluştur'),
            ),
            const SizedBox(height: 20),
            _isQrGenerated
                ? RepaintBoundary(
                    key: _qrKey,
                    child: _qrData.isNotEmpty
                        ? QrImageView(
                            data: _qrData,
                            version: QrVersions.auto,
                            size: 200.0,
                          )
                        : const SizedBox.shrink(),
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isQrGenerated ? _saveQrCode : null,
              child: const Text('QR Kodunu Kaydet'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isQrGenerated ? _printQrCode : null,
              child: const Text('QR Kodunu Yazdır'),
            ),
          ],
        ),
      ),
    );
  }
}

class PdfPreviewScreen extends StatelessWidget {
  final String pdfUrl;

  const PdfPreviewScreen({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Önizleme")),
      body: PDF().cachedFromUrl(
        pdfUrl,
        placeholder: (progress) =>
            Center(child: Text('$progress % yükleniyor...')),
        errorWidget: (error) =>
            Center(child: Text('PDF yüklenirken hata oluştu: $error')),
      ),
    );
  }
}
