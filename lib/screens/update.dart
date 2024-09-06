import 'package:flutter/material.dart';
import 'package:ornek_proje/screens/qr_code_create_choose.dart';

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
                  fontSize: 18,
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
          buildMenuButton('Dosyadan Yükle', context),
          buildMenuButton('Link ile Yükle', context),
          buildMenuButton('QR ile Yükle', context, isLast: true),
        ],
      ),
    );
  }

  ElevatedButton buildMenuButton(String text, BuildContext context,
      {bool isLast = false}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFFCC00), // Sarı renk
        shape: RoundedRectangleBorder(
          borderRadius: isLast
              ? BorderRadius.vertical(bottom: Radius.circular(10))
              : BorderRadius.zero,
        ),
      ),
      onPressed: () {
        // İlgili fonksiyonlar burada çalışacak
        if (text == 'Dosyadan Yükle') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QrCodeCreateChoose(),
            ),
          );
        }
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
