import 'package:flutter/material.dart';
import 'package:ornek_proje/screens/user.dart';
import 'package:ornek_proje/screens/update.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF041a25), // Mavi arka plan rengi
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF041a25), // Mavi renk
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.cloud_upload,
                  color: Color(0xFFFFCC00), size: 30), // Sarı renk
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25.0)),
                  ),
                  builder: (BuildContext context) {
                    return UpdateMenu();
                  },
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person,
                  color: Color(0xFFFFCC00), size: 30), // Sarı renk
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25.0)),
                  ),
                  builder: (BuildContext context) {
                    return UserMenu();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
