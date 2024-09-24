import 'package:flutter/material.dart';
import 'package:ornek_proje/screens/file_upload.dart';
import 'package:ornek_proje/screens/qr_upload.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

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
                'Yükle',
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
          SizedBox(height: 8),
          buildMenuButton('Dosyadan Yükle', context, isFirst: true),
          buildMenuButton('Link ile Yükle', context),
          buildMenuButton('QR ile Yükle', context, isLast: true),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  ElevatedButton buildMenuButton(String text, BuildContext context,
      {bool isFirst = false, bool isLast = false}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFFCC00),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: isFirst ? Radius.circular(10) : Radius.zero,
            topRight: isFirst ? Radius.circular(10) : Radius.zero,
            bottomLeft: isLast ? Radius.circular(10) : Radius.zero,
            bottomRight: isLast ? Radius.circular(10) : Radius.zero,
          ),
        ),
      ),
      onPressed: () {
        if (text == 'Link ile Yükle') {
          _showLinkUploadSheet(context);
        } else if (text == 'Dosyadan Yükle') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FileUpload()),
          ).then((result) {
            if (result != null && result is PdfItem) {
              Navigator.pop(context, result); // PDF'i geri gönder
            }
          });
        } else if (text == 'QR ile Yükle') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QrUpload()),
          ).then((result) {
            if (result != null && result is PdfItem) {
              Navigator.pop(context, result); // PDF'i geri gönder
            }
          });
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: TextStyle(color: Colors.black)),
          Icon(Icons.arrow_forward_ios, color: Colors.black),
        ],
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
        // PdfPreviewScreen'den gelen sonucu bekleyin
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => pdfPreviewScreen),
        );

        // Eğer kullanıcı kaydettiyse PdfItem olarak geri döner
        if (result != null && result is PdfItem) {
          Navigator.pop(context, result); // PdfItem'i geri gönder
        }

        print("Navigator.push tamamlandı");
      } catch (e) {
        print("PDF önizleme hatası: $e");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF önizleme sırasında bir hata oluştu: $e')),
        );
      }
    } else {
      print("Geçersiz URL");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçersiz Google Drive PDF linki!')),
      );
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
}

class PdfPreviewScreen extends StatefulWidget {
  final String pdfUrl;
  final String initialPdfName;

  PdfPreviewScreen({
    Key? key,
    required this.pdfUrl,
    required this.initialPdfName,
  }) : super(key: key);

  @override
  _PdfPreviewScreenState createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  late String pdfName;

  @override
  void initState() {
    super.initState();
    pdfName = widget.initialPdfName;
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
            child: PDF().cachedFromUrl(
              widget.pdfUrl,
              placeholder: (progress) =>
                  Center(child: Text('$progress % yükleniyor...')),
              errorWidget: (error) =>
                  Center(child: Text('PDF yüklenirken hata oluştu: $error')),
            ),
          ),
          Container(
            color: Color(0xFF041a25),
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      print("Kaydet butonuna basıldı");
                      // PdfItem olarak geri gönder
                      Navigator.pop(
                          context, PdfItem(name: pdfName, url: widget.pdfUrl));
                    },
                    icon: Icon(Icons.save, color: Colors.black),
                    label:
                        Text('Kaydet', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFCC00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      print("Sil butonuna basıldı");
                      // Silme işlemi için geri dön
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.delete, color: Colors.black),
                    label: Text('Sil', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFCC00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
