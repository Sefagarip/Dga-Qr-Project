import 'package:flutter/material.dart';
import 'package:ornek_proje/screens/file_upload.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UpdateMenu extends StatefulWidget {
  const UpdateMenu({Key? key}) : super(key: key);

  @override
  _UpdateMenuState createState() => _UpdateMenuState();
}

class PdfItem {
  final String name;
  final String url;

  PdfItem({required this.name, required this.url});
}

class _UpdateMenuState extends State<UpdateMenu> {
  String pdfName = '';
  String pdfUrl = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
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
                '     Yükle',
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
          SizedBox(height: 10),
          Column(
            children: [
              _buildUpdateActionButton(
                label: 'Dosyadan Yükle',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FileUpload()),
                  ).then((result) {
                    if (result != null && result is PdfItem) {
                      Navigator.pop(context, result);
                    }
                  });
                },
                isFirst: true,
              ),
              SizedBox(height: 1),
              _buildUpdateActionButton(
                label: 'Link ile Yükle',
                onPressed: () {
                  _showLinkUploadSheet(context);
                },
              ),
              SizedBox(height: 1),
              _buildUpdateActionButton(
                label: 'QR ile Yükle',
                onPressed: () {
                  _startQrScan(context);
                },
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateActionButton({
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
            Text(
              label,
              style: TextStyle(color: Color(0xFF041a25), fontSize: 14),
            ),
            Icon(Icons.chevron_right, color: Color(0xFF041a25), size: 20),
          ],
        ),
      ),
    );
  }

  void _showLinkUploadSheet(BuildContext context) {
    String linkText = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: Color(0xFF041a25),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Link ile Yükle',
                        style: TextStyle(
                          color: Color(0xFFFFCC00),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Color(0xFFFFCC00)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      hintText: 'https://drive.google.com/...',
                      hintStyle: TextStyle(color: Color(0xFFFFCC00)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFFCC00)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFFCC00)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    style: TextStyle(color: Color(0xFFFFCC00)),
                    onChanged: (value) {
                      setState(() => linkText = value);
                      print("Girilen URL: $value");
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFCC00),
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () async {
                      if (linkText.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Lütfen geçerli bir URL girin.')),
                        );
                        return;
                      }
                      print("PDF Önizleme Göster butonuna basıldı");
                      print("Gönderilen URL: $linkText");
                      Navigator.pop(context);
                      _previewPdf(linkText);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PDF Önizleme Göster',
                            style: TextStyle(color: Colors.black)),
                        Icon(Icons.arrow_forward_ios, color: Colors.black),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

  Future<void> _previewPdf(String url) async {
    print("Önizleme için gelen URL: $url");
    if (_isValidDriveLink(url)) {
      try {
        final formattedUrl = _formatDriveLink(url);
        print("Önizleme için kullanılacak URL: $formattedUrl");
        String pdfName = await _getPdfNameFromUrl(url);
        print("PDF adı: $pdfName");

        if (!mounted) return;

        print("PdfPreviewScreen oluşturuluyor");
        final pdfPreviewScreen = PdfPreviewScreen(
          pdfUrl: formattedUrl,
          initialPdfName: pdfName,
        );

        print("Navigator.push çağrılıyor");
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => pdfPreviewScreen),
        );

        if (result != null && result is PdfItem) {
          Navigator.pop(context, result);
        }

        print("Navigator.push tamamlandı");
      } catch (e) {
        print("PDF önizleme hatası: $e");
        if (!mounted) return;
        _showErrorInPdfPreview(
            context, 'PDF önizleme sırasında bir hata oluştu: $e');
      }
    } else {
      print("Geçersiz URL");
      if (!mounted) return;
      _showErrorInPdfPreview(context, 'Geçersiz Google Drive PDF linki!');
    }
  }

  String _formatDriveLink(String url) {
    print("Biçimlendirilen URL: $url");
    String fileId;
    if (url.contains('drive.google.com/file/d/')) {
      fileId = url.split('/d/')[1].split('/')[0];
    } else if (url.contains('drive.google.com/open?id=')) {
      fileId = url.split('id=')[1].split('&')[0];
    } else {
      print("Bilinmeyen URL formatı, orijinal URL döndürülüyor");
      return url;
    }
    String formattedUrl =
        'https://drive.google.com/uc?export=download&id=$fileId';
    print("Biçimlendirilmiş URL: $formattedUrl");
    return formattedUrl;
  }

  bool _isValidDriveLink(String url) {
    print("Kontrol edilen URL: $url");
    bool isValid = url.contains('drive.google.com/file/d/') ||
        url.contains('drive.google.com/open?id=') ||
        (url.contains('drive.google.com/file/d/') &&
            url.contains('view?usp=drive_link'));
    print("URL geçerli mi? $isValid");
    return isValid;
  }

  Future<void> _startQrScan(BuildContext context) async {
    try {
      String scanResult = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "İptal",
        true,
        ScanMode.QR,
      );

      if (scanResult != '-1') {
        String? directLink = _convertToDirectDownloadLink(scanResult);
        if (directLink != null) {
          String pdfName = await _getPdfNameFromUrl(directLink);
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfPreviewScreen(
                pdfUrl: directLink,
                initialPdfName: pdfName,
              ),
            ),
          );
          if (result != null && result is PdfItem) {
            Navigator.pop(context, result);
          }
        } else {
          _showErrorInPdfPreview(context, 'Desteklenmeyen bir link formatı.');
        }
      }
    } catch (e) {
      _showErrorInPdfPreview(context, 'Tarama başarısız oldu: $e');
    }
  }

  void _showErrorInPdfPreview(BuildContext context, String errorMessage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewScreen(
          pdfUrl: '',
          initialPdfName: 'Hata',
          initialErrorMessage: errorMessage,
        ),
      ),
    );
  }

  String? _convertToDirectDownloadLink(String url) {
    if (url.contains("dropbox.com")) {
      return url.replaceFirst(RegExp(r'dl=0$'), 'dl=1');
    } else if (url.contains("drive.google.com")) {
      final fileId = RegExp(r'd/([^/]+)').firstMatch(url)?.group(1);
      return fileId != null
          ? 'https://drive.google.com/uc?export=download&id=$fileId'
          : null;
    }
    return url;
  }
}

class PdfPreviewScreen extends StatefulWidget {
  final String pdfUrl;
  final String initialPdfName;
  final String? initialErrorMessage;

  PdfPreviewScreen({
    Key? key,
    required this.pdfUrl,
    required this.initialPdfName,
    this.initialErrorMessage,
  }) : super(key: key);

  @override
  _PdfPreviewScreenState createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  late String pdfName;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    pdfName = widget.initialPdfName;
    errorMessage = widget.initialErrorMessage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                pdfName,
                style: TextStyle(color: Color(0xFFFFCC00)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Color(0xFFFFCC00)),
              onPressed: () => _showEditDialog(context),
            ),
          ],
        ),
        backgroundColor: Color(0xFF041a25),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFFFCC00)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: errorMessage != null
                ? Center(
                    child: Text(
                      'PDF yüklenirken hata oluştu: $errorMessage',
                      textAlign: TextAlign.center,
                    ),
                  )
                : PDF().cachedFromUrl(
                    widget.pdfUrl,
                    placeholder: (progress) => Center(
                      child: CircularProgressIndicator(
                        value: progress,
                      ),
                    ),
                    errorWidget: (error) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() => errorMessage = error.toString());
                      });
                      return Center(
                        child: Text('PDF yüklenirken hata oluştu: $error'),
                      );
                    },
                  ),
          ),
          Container(
            color: Color(0xFF041a25),
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.qr_code,
                  label: 'QR Oluştur',
                  onPressed: () => _showQRCode(context),
                ),
                _buildActionButton(
                  icon: Icons.save,
                  label: 'Kaydet',
                  onPressed: () {
                    print("Kaydet butonuna basıldı");
                    Navigator.pop(
                        context, PdfItem(name: pdfName, url: widget.pdfUrl));
                  },
                ),
                _buildActionButton(
                  icon: Icons.delete,
                  label: 'Sil',
                  onPressed: () {
                    print("Sil butonuna basıldı");
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Color(0xFFFFCC00)),
          onPressed: onPressed,
        ),
        Text(label, style: TextStyle(color: Color(0xFFFFCC00))),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    TextEditingController _controller = TextEditingController(text: pdfName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF041a25),
          title: Text('Başlığı Düzenle',
              style: TextStyle(color: Color(0xFFFFCC00))),
          content: TextField(
            controller: _controller,
            style: TextStyle(color: Color(0xFFFFCC00)),
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFCC00))),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFCC00))),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('İptal', style: TextStyle(color: Color(0xFFFFCC00))),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Kaydet', style: TextStyle(color: Color(0xFFFFCC00))),
              onPressed: () {
                setState(() => pdfName = _controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showQRCode(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 280,
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
                    'QR Kodu',
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
              SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: QrImageView(
                    data: widget.pdfUrl,
                    version: QrVersions.auto,
                    size: 200.0,
                    foregroundColor: Color(0xFFFFCC00),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQRActionButton(
                    icon: Icons.save,
                    label: 'Kaydet',
                    onPressed: () {
                      // Kaydetme işlevi buraya eklenecek
                    },
                  ),
                  _buildQRActionButton(
                    icon: Icons.share,
                    label: 'Paylaş',
                    onPressed: () {
                      // Paylaşma işlevi buraya eklenecek
                    },
                  ),
                  _buildQRActionButton(
                    icon: Icons.print,
                    label: 'Yazdır',
                    onPressed: () {
                      // Yazdırma işlevi buraya eklenecek
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQRActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Color(0xFFFFCC00)),
          onPressed: onPressed,
        ),
        Text(label, style: TextStyle(color: Color(0xFFFFCC00))),
      ],
    );
  }
}
