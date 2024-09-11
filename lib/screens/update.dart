import 'package:flutter/material.dart';
import 'package:ornek_proje/screens/file_upload.dart';
import 'package:ornek_proje/screens/link_upload.dart';
import 'package:ornek_proje/screens/qr_upload.dart';

class UpdateMenu extends StatelessWidget {
  const UpdateMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF041a25), // Mavi renk
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
                  color: Color(0xFFFFCC00), // Sarı renk
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: Color(0xFFFFCC00)), // Sarı renk
                onPressed: () {
                  Navigator.pop(context); // Sheet'i kapatır
                },
              ),
            ],
          ),
          SizedBox(height: 8),
          buildMenuButton('Dosyadan Yükle', context, isFirst: true),
          buildMenuButton('Link ile Yükle', context),
          buildMenuButton('QR ile Yükle', context, isLast: true),
        ],
      ),
    );
  }

  ElevatedButton buildMenuButton(String text, BuildContext context,
      {bool isFirst = false, bool isLast = false}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFFCC00), // Sarı renk
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
        // İlgili sayfaları açan kodlar
        if (text == 'Dosyadan Yükle') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FileUpload(),
            ),
          );
        } else if (text == 'Link ile Yükle') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LinkUpload(),
            ),
          );
        } else if (text == 'QR ile Yükle') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QrUpload(),
            ),
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(color: Colors.black),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.black), // ">" simgesi
        ],
      ),
    );
  }
}
