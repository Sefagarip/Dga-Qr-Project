import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:ornek_proje/screens/database_helper.dart';
import 'package:ornek_proje/screens/user.dart';

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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.readonly'],
  );

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
                  _showGoogleDrivePdfList(context);
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
          isViewOnly: true,
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

  // Google Drive PDF listesini gösteren yeni fonksiyon
  void _showGoogleDrivePdfList(BuildContext context) async {
    // Google hesabı kontrolü
    final googleAccount = await _checkGoogleAccount();
    if (googleAccount == null) {
      _showSignInDialog(context);
      return;
    }

    // Google Drive'dan PDF listesini al
    final pdfList = await _getGoogleDrivePdfList(googleAccount);

    // PDF listesini göster
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF041a25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.42,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Google Drive PDF\'leri',
                      style: TextStyle(
                        color: Color(0xFFFFCC00),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Color(0xFFFFCC00)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: pdfList.length,
                  itemBuilder: (context, index) {
                    final pdf = pdfList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0),
                      child: Container(
                        height: 40, // Yükle sayfasındaki gibi yükseklik
                        decoration: BoxDecoration(
                          color: Color(0xFFFFCC00),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              Navigator.pop(context);
                              _previewPdf(pdf.url);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      pdf.name,
                                      style: TextStyle(
                                          color: Color(0xFF041a25),
                                          fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(Icons.chevron_right,
                                      color: Color(0xFF041a25), size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSignInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Google Hesabı Gerekli'),
          content: Text(
              'Google Drive\'dan PDF yüklemek için önce Google hesabınızla giriş yapmanız gerekmektedir.'),
          actions: <Widget>[
            TextButton(
              child: Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Giriş Yap'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // UpdateMenu'yü kapat
                _openUserMenu(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _openUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return UserMenu();
      },
    );
  }

  // Google hesabı kontrolü için yeni fonksiyon
  Future<GoogleSignInAccount?> _checkGoogleAccount() async {
    GoogleSignInAccount? account = await _googleSignIn.signInSilently();
    return account;
  }

  // Google Drive'dan PDF listesini almak için yeni fonksiyon
  Future<List<PdfItem>> _getGoogleDrivePdfList(
      GoogleSignInAccount account) async {
    final headers = await account.authHeaders;
    final client = GoogleHttpClient(headers);
    final driveApi = drive.DriveApi(client);

    final fileList = await driveApi.files.list(
      q: "mimeType='application/pdf'",
      spaces: 'drive',
      $fields: 'files(id, name, webViewLink)',
    );

    return fileList.files!
        .map((file) => PdfItem(
              name: file.name ?? 'Adsız PDF',
              url: file.webViewLink ?? '',
            ))
        .toList();
  }
}

class PdfPreviewScreen extends StatefulWidget {
  final String pdfUrl;
  final String initialPdfName;
  final bool isViewOnly;
  final String? initialErrorMessage;

  PdfPreviewScreen({
    Key? key,
    required this.pdfUrl,
    required this.initialPdfName,
    this.isViewOnly = false,
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
        title: Text(
          pdfName,
          style: TextStyle(color: Color(0xFFFFCC00)),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Color(0xFF041a25),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFFFCC00)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: widget.isViewOnly
            ? []
            : [
                IconButton(
                  icon: Icon(Icons.edit, color: Color(0xFFFFCC00)),
                  onPressed: () => _showEditDialog(context),
                ),
              ],
      ),
      body: errorMessage != null
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
      bottomNavigationBar: widget.isViewOnly
          ? null
          : Container(
              color: Color(0xFF041a25),
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.save,
                    label: 'Kaydet',
                    onPressed: () async {
                      print("Kaydet butonuna basıldı");
                      final newPdf = PdfItem(name: pdfName, url: widget.pdfUrl);
                      await DatabaseHelper.instance.insertPdf(newPdf);
                      Navigator.pop(context, newPdf);
                    },
                  ),
                  SizedBox(width: 50),
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
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Color(0xFFFFCC00), size: 24),
          Text(
            label,
            style: TextStyle(color: Color(0xFFFFCC00), fontSize: 10),
          ),
        ],
      ),
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
}

class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
