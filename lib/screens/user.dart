import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserMenu extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.readonly'],
  );

  UserMenu({Key? key}) : super(key: key);

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${account.displayName} olarak giriş yapıldı')),
        );
        Navigator.pop(context); // Menüyü kapat
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş yapılırken bir hata oluştu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.43,
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
                '    Kullanıcı',
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
              _buildUserActionButton(
                label: 'Proje Dizini Seç',
                onPressed: () {
                  // Proje dizini seçme işlevi
                },
                isFirst: true,
              ),
              SizedBox(height: 1),
              _buildUserActionButton(
                label: 'Google ile Giriş Yap',
                onPressed: () => _handleSignIn(context),
                isLast: true, // Bu butonu son buton olarak işaretledik
              ),
              SizedBox(height: 16),
              _buildUserActionButton(
                label: 'Geri Bildirim',
                onPressed: () {
                  // Geri bildirim işlevi
                },
                isFirst: true,
              ),
              SizedBox(height: 1),
              _buildUserActionButton(
                label: 'Online Yardım',
                onPressed: () {
                  // Online yardım işlevi
                },
              ),
              SizedBox(height: 1),
              _buildUserActionButton(
                label: 'İndirilenler',
                onPressed: () {
                  // İndirilenler işlevi
                },
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserActionButton({
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
}
