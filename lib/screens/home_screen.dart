import 'package:flutter/material.dart';
import 'package:ornek_proje/screens/user.dart';
import 'package:ornek_proje/screens/update.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // FocusNode değişikliklerini dinle
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF041a25), // Mavi arka plan rengi
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0), // AppBar yüksekliği
        child: AppBar(
          backgroundColor: Color(0xFF041a25), // Mavi renk
          title: _isSearching
              ? GestureDetector(
                  onTap: () {
                    // Arama alanına tıklama durumunda odaklanma
                    FocusScope.of(context).requestFocus(_focusNode);
                  },
                  child: Row(
                    children: [
                      // Arama alanı sarı arka planlı
                      Expanded(
                        child: Container(
                          color: Color(0xFFFFCC00), // Sarı arka plan
                          child: TextField(
                            autofocus: true,
                            focusNode: _focusNode,
                            style: TextStyle(
                              color: Color(0xFF041a25), // Mavi yazı
                              fontSize: 18, // Metin boyutu
                            ),
                            decoration: InputDecoration(
                              hintText: '🔍', // Arama emojisi hint alanında
                              hintStyle: TextStyle(
                                fontSize: 16, // Küçük emoji
                                color: Colors.grey[400], // Renksiz emoji
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10), // İçerik boşluğu
                            ),
                          ),
                        ),
                      ),
                      // Çarpı butonu
                      Container(
                        color: Color(0xFFFFCC00), // Sarı arka plan
                        child: IconButton(
                          icon: Icon(Icons.close,
                              color: Color(0xFF041a25)), // Mavi çarpı
                          onPressed: () {
                            setState(() {
                              _isSearching = false; // Arama durumu kapatılır
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Projeler',
                      style: TextStyle(
                        color: Color(0xFFFFCC00), // Sarı renk
                        fontWeight: FontWeight.bold, // Kalın yazı
                        fontSize: 24, // Başlık boyutu
                      ),
                    ),
                    // Sarı arka planlı arama butonu
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFCC00), // Sarı arka plan
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.search,
                            color: Color(0xFF041a25)), // Mavi arama ikonu
                        onPressed: () {
                          setState(() {
                            _isSearching = true; // Arama durumu açılır
                          });
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (_isSearching) {
            FocusScope.of(context).unfocus(); // Klavyeyi kapat
          }
        },
        child: Container(
          color: Colors.transparent, // Ekran arka planı
          child: Center(
            child: Text(
              'Ana içerik alanı', // Ana içerik
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 62, // Keep the height at 58
        child: BottomAppBar(
          color: Color.fromARGB(255, 7, 44, 62), // Background color
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment:
                CrossAxisAlignment.center, // Align icons and text vertically
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25.0)),
                    ),
                    builder: (BuildContext context) {
                      return UpdateMenu(); // Call UpdateMenu on tap
                    },
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center items vertically
                  children: [
                    Icon(Icons.cloud_upload,
                        color: Color(0xFFFFCC00), size: 24), // Icon
                    Text(
                      'Yükle', // Text label
                      style: TextStyle(
                          color: Color(0xFFFFCC00),
                          fontSize: 10), // Smaller font size
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25.0)),
                    ),
                    builder: (BuildContext context) {
                      return UserMenu(); // Call UserMenu on tap
                    },
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center items vertically
                  children: [
                    Icon(Icons.person,
                        color: Color(0xFFFFCC00), size: 24), // Icon
                    Text(
                      'Kullanıcı', // Text label
                      style: TextStyle(
                          color: Color(0xFFFFCC00),
                          fontSize: 10), // Smaller font size
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
