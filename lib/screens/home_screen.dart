import 'package:flutter/material.dart';
import 'package:ornek_proje/screens/qr_code_create.dart';
import 'package:ornek_proje/screens/qr_code_create_choose.dart';
import 'package:ornek_proje/screens/qr_code_scan.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF156082),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0), // Resmi aşağı çek
            child: Center(
              child: Image.asset(
                "assets/images/5_DGA-Logo-Mottosuz-8010x3810-1.webp",
              ),
            ),
          ),
          SizedBox(height: 150), // Resim ile ilk buton arasında boşluk
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 70, 176, 222), // Buton rengi
              fixedSize: Size(300, 75), // Buton boyutunu ayarla
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QrCodeCreate(),
                ),
              );
            },
            child: Text('QR OLUŞTUR(link ile)'),
          ),
          SizedBox(height: 50), // İlk buton ile ikinci buton arasında boşluk
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 70, 176, 222), // Buton rengi
              fixedSize: Size(300, 75), // Buton boyutunu ayarla
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QrCodeCreateChoose(), // Yeni sayfa
                ),
              );
            },
            child: Text('QR OLUŞTUR(seçerek)'), // Yeni buton
          ),
          SizedBox(height: 50), // İkinci buton ile üçüncü buton arasında boşluk
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 70, 176, 222), // Buton rengi
              fixedSize: Size(300, 75), // Buton boyutunu ayarla
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QrCodeScan(),
                ),
              );
            },
            child: Text('QR OKUT'),
          ),
        ],
      ),
    );
  }
}
