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
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class FileUpload extends StatefulWidget {
  const FileUpload({super.key});

  @override
  _FileUploadState createState() => _FileUploadState();
}

class _FileUploadState extends State<FileUpload> {
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );
  GoogleSignInAccount? _currentUser;
  String? _selectedPdfLink;
  final GlobalKey _qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _googleSignIn.signInSilently();
  }

  Future<void> _selectPdfAndGenerateQrCode() async {
    final user = await _googleSignIn.signIn();
    if (user == null) return;
    _currentUser = user;

    final authHeaders = await _currentUser!.authHeaders;
    final client = http.Client();
    final authenticatedClient = AuthenticatedClient(client, authHeaders);
    final driveApi = drive.DriveApi(authenticatedClient);
    final fileList = await driveApi.files.list(q: "mimeType='application/pdf'");

    final selectedFile = await showDialog<drive.File>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('PDF Seç'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: fileList.files!.length,
              itemBuilder: (context, index) {
                final file = fileList.files![index];
                return ListTile(
                  title: Text(file.name!),
                  onTap: () {
                    Navigator.of(context).pop(file);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedFile == null) return;

    final shareableLink = await driveApi.files
        .get(selectedFile.id!, $fields: 'webViewLink') as drive.File;

    setState(() {
      _selectedPdfLink = shareableLink.webViewLink!;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Kod Oluşturucu')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _selectPdfAndGenerateQrCode,
              child: Text('PDF Seç'),
            ),
            if (_selectedPdfLink != null)
              RepaintBoundary(
                key: _qrKey,
                child: QrImageView(
                  data: _selectedPdfLink!,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
            if (_selectedPdfLink != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveQrCode,
                child: const Text('QR Kodunu Kaydet'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _printQrCode,
                child: const Text('QR Kodunu Yazdır'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AuthenticatedClient extends http.BaseClient {
  final http.Client _client;
  final Map<String, String> _headers;

  AuthenticatedClient(this._client, this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
