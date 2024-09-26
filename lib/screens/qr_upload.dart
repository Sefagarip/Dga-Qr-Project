import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart'; // PDF önizleme ve önbellekleme için
import 'package:ornek_proje/screens/update.dart'; // PdfItem ve PdfPreviewScreen için

class QrUpload extends StatelessWidget {
  const QrUpload({Key? key}) : super(key: key);

  Future<void> _startScan(BuildContext context) async {
    try {
      String scanResult = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", // Tarama ekranında kullanılacak renk
        "İptal", // İptal butonu metni
        true, // Flaş aç/kapa
        ScanMode.QR,
      );

      if (scanResult != '-1') {
        String? directLink = _convertToDirectDownloadLink(scanResult);
        if (directLink != null) {
          String pdfName = await _getPdfNameFromUrl(directLink);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfPreviewScreen(
                pdfUrl: directLink,
                initialPdfName: pdfName,
              ),
            ),
          ).then((result) {
            if (result != null && result is PdfItem) {
              Navigator.pop(context, result); // PDF'i geri gönder
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Desteklenmeyen bir link formatı.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarama başarısız oldu: $e')),
      );
    }
  }

  // Linki doğrudan indirme linkine dönüştürme fonksiyonu
  String? _convertToDirectDownloadLink(String url) {
    if (url.contains("dropbox.com")) {
      return url.replaceFirst(RegExp(r'dl=0$'), 'dl=1');
    } else if (url.contains("drive.google.com")) {
      final fileId = RegExp(r'd/([^/]+)').firstMatch(url)?.group(1);
      return fileId != null
          ? 'https://drive.google.com/uc?export=download&id=$fileId'
          : null;
    }
    return url; // Diğer URL'ler için doğrudan URL'yi döndür
  }

  Future<String> _getPdfNameFromUrl(String url) async {
    try {
      Uri uri = Uri.parse(url);
      if (url.contains('drive.google.com')) {
        String fileName = uri.queryParameters['title'] ?? 'Document.pdf';
        if (fileName == 'Document.pdf' && uri.pathSegments.length > 1) {
          fileName = Uri.decodeComponent(
              uri.pathSegments[uri.pathSegments.length - 2]);
        }
        if (!fileName.toLowerCase().endsWith('.pdf')) {
          fileName += '.pdf';
        }
        return fileName;
      } else {
        String fileName = uri.pathSegments.last;
        return fileName.contains('.')
            ? Uri.decodeComponent(fileName)
            : 'Document.pdf';
      }
    } catch (e) {
      print('Error getting PDF name: $e');
      return 'Document.pdf';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kamerayı hemen aç
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScan(context);
    });

    // Boş bir sayfa döndür, çünkü kamera hemen açılacak
    return Scaffold(
      body: Container(),
    );
  }
}

class PDFViewerPage extends StatelessWidget {
  final String pdfUrl;

  const PDFViewerPage({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Önizleme'),
      ),
      body: const PDF().cachedFromUrl(
        pdfUrl,
        placeholder: (progress) => Center(
          child: Text('$progress% yükleniyor...'),
        ),
        errorWidget: (error) => Center(
          child: Text('PDF yüklenirken hata oluştu: $error'),
        ),
      ),
    );
  }
}
