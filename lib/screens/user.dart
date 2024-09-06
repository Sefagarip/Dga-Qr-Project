import 'package:flutter/material.dart';

class UserMenu extends StatelessWidget {
  const UserMenu({super.key});

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
                'Kullanıcı',
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
          buildMenuButton('Proje Dizini Seç', context),
          buildMenuButton('Google ile Giriş Yap', context),
          buildMenuButton('Geri Bildirim', context),
          buildMenuButton('Online Yardım', context),
          buildMenuButton('İndirilenler', context, isLast: true),
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
      },
      child: Align(
        alignment: Alignment.centerLeft,
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
      ),
    );
  }
}
