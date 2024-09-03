import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart'; // PDF önizleme ve önbellekleme için

class QrCodeScan extends StatefulWidget {
  const QrCodeScan({super.key});

  @override
  _QrCodeScanState createState() => _QrCodeScanState();
}

class _QrCodeScanState extends State<QrCodeScan> {
  String _scanResult = "Henüz taranmadı";

  Future<void> _startScan() async {
    try {
      String scanResult = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", // Tarama ekranında kullanılacak renk
        "İptal", // İptal butonu metni
        true, // Flaş aç/kapa
        ScanMode.QR,
      );

      if (!mounted) return;

      setState(() {
        _scanResult = scanResult != '-1' ? scanResult : 'Tarama iptal edildi';
      });

      if (_scanResult != '-1') {
        String? directLink = _convertToDirectDownloadLink(_scanResult);
        if (directLink != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewerPage(pdfUrl: directLink),
            ),
          );
        } else {
          setState(() {
            _scanResult = 'Desteklenmeyen bir link formatı.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _scanResult = 'Tarama başarısız oldu: $e';
      });
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
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Kod Tarayıcı'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tarama Sonucu:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              _scanResult,
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startScan,
              child: const Text('QR Kodu Tara'),
            ),
          ],
        ),
      ),
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
