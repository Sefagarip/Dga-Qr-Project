import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:ornek_proje/screens/update.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class FileUpload extends StatefulWidget {
  const FileUpload({Key? key}) : super(key: key);

  @override
  _FileUploadState createState() => _FileUploadState();
}

class _FileUploadState extends State<FileUpload> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveReadonlyScope],
  );
  drive.DriveApi? _driveApi;

  @override
  void initState() {
    super.initState();
    _initializeDriveApi();
  }

  Future<void> _initializeDriveApi() async {
    final googleUser = await _googleSignIn.signInSilently();
    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      final authHeaders = await googleUser.authHeaders;
      final authenticatedClient = GoogleAuthClient(authHeaders);
      _driveApi = drive.DriveApi(authenticatedClient);
    }
  }

  Future<void> _listAndSelectPdf(BuildContext context) async {
    if (_driveApi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen önce Google hesabınıza giriş yapın')),
      );
      return;
    }

    try {
      final files = await _driveApi!.files.list(
        q: "mimeType='application/pdf'",
        $fields: "files(id, name)",
      );

      if (files.files == null || files.files!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hiç PDF dosyası bulunamadı')),
        );
        return;
      }

      final selectedFile = await showDialog<drive.File>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('PDF Seçin'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: files.files!.length,
              itemBuilder: (context, index) {
                final file = files.files![index];
                return ListTile(
                  title: Text(file.name ?? 'İsimsiz Dosya'),
                  onTap: () => Navigator.of(context).pop(file),
                );
              },
            ),
          ),
        ),
      );

      if (selectedFile != null) {
        final tempFile = await _downloadAndSavePdf(selectedFile);
        if (tempFile != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfPreviewScreen(
                pdfFile: tempFile,
                pdfName: selectedFile.name!,
              ),
            ),
          ).then((result) {
            if (result != null && result is PdfItem) {
              Navigator.pop(context, result);
            }
          });
        }
      }
    } catch (e) {
      print('PDF listeleme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF dosyaları listelenirken bir hata oluştu')),
      );
    }
  }

  Future<File?> _downloadAndSavePdf(drive.File file) async {
    try {
      final content = await _driveApi!.files.get(file.id!,
          downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      final bytes = await _streamToUint8List(content.stream);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${file.name}');
      await tempFile.writeAsBytes(bytes);
      return tempFile;
    } catch (e) {
      print('PDF indirme hatası: $e');
      return null;
    }
  }

  Future<Uint8List> _streamToUint8List(Stream<List<int>> stream) async {
    final chunks = await stream.toList();
    return Uint8List.fromList(chunks.expand((x) => x).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PDF Seç')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _listAndSelectPdf(context),
          child: Text('PDF Dosyalarını Listele'),
        ),
      ),
    );
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class PdfPreviewScreen extends StatelessWidget {
  final File pdfFile;
  final String pdfName;

  const PdfPreviewScreen(
      {Key? key, required this.pdfFile, required this.pdfName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pdfName),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              Navigator.pop(context, PdfItem(name: pdfName, url: pdfFile.path));
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              final xFile = XFile(pdfFile.path);
              Share.shareXFiles([xFile], text: 'PDF Dosyası: $pdfName');
            },
          ),
        ],
      ),
      body: SfPdfViewer.file(pdfFile),
    );
  }
}
