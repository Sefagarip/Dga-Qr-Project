import 'package:flutter/material.dart';
import 'package:ornek_proje/screens/user.dart';
import 'package:ornek_proje/screens/update.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final FocusNode _focusNode = FocusNode();
  List<PdfItem> pdfItems = [];
  int? expandedIndex;

  @override
  void initState() {
    super.initState();
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
      backgroundColor: Color(0xFF041a25),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: Color(0xFF041a25),
          title: _isSearching
              ? GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(_focusNode);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: Color(0xFFFFCC00),
                          child: TextField(
                            autofocus: true,
                            focusNode: _focusNode,
                            style: TextStyle(
                              color: Color(0xFF041a25),
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              hintText: '🔍',
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: Color(0xFFFFCC00),
                        child: IconButton(
                          icon: Icon(Icons.close, color: Color(0xFF041a25)),
                          onPressed: () {
                            setState(() {
                              _isSearching = false;
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
                        color: Color(0xFFFFCC00),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFCC00),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.search, color: Color(0xFF041a25)),
                        onPressed: () {
                          setState(() {
                            _isSearching = true;
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
            FocusScope.of(context).unfocus();
          }
        },
        child: Container(
          color: Colors.transparent,
          child: pdfItems.isEmpty
              ? Center(
                  child: Text(
                    'Henüz PDF yüklenmedi',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: pdfItems.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFCC00),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                pdfItems[index].name,
                                style: TextStyle(color: Color(0xFF041a25)),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  expandedIndex == index
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  color: Color(0xFF041a25),
                                ),
                                onPressed: () {
                                  setState(() {
                                    expandedIndex =
                                        expandedIndex == index ? null : index;
                                  });
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  expandedIndex =
                                      expandedIndex == index ? null : index;
                                });
                              },
                            ),
                            if (expandedIndex == index)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.visibility,
                                              color: Color(0xFF041a25)),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PdfPreviewScreen(
                                                  pdfUrl: pdfItems[index].url,
                                                  initialPdfName:
                                                      pdfItems[index].name,
                                                ),
                                              ),
                                            );
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                        ),
                                        Text('Göster',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF041a25))),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Color(0xFF041a25)),
                                          onPressed: () {
                                            setState(() {
                                              pdfItems.removeAt(index);
                                              expandedIndex = null;
                                            });
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                        ),
                                        Text('Sil',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF041a25))),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.qr_code,
                                              color: Color(0xFF041a25)),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('QR Kodu'),
                                                  content: Container(
                                                    width: 200,
                                                    height: 200,
                                                    child: Center(
                                                      child: Text(
                                                          'QR Kodu Burada Gösterilecek'),
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text('Kapat'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                        ),
                                        Text('QR Göster',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF041a25))),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 62,
        child: BottomAppBar(
          color: Color.fromARGB(255, 7, 44, 62),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                      return UpdateMenu();
                    },
                  ).then((result) {
                    if (result != null && result is PdfItem) {
                      setState(() {
                        pdfItems.add(result);
                      });
                    }
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload,
                        color: Color(0xFFFFCC00), size: 24),
                    Text(
                      'Yükle',
                      style: TextStyle(color: Color(0xFFFFCC00), fontSize: 10),
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
                      return UserMenu();
                    },
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, color: Color(0xFFFFCC00), size: 24),
                    Text(
                      'Kullanıcı',
                      style: TextStyle(color: Color(0xFFFFCC00), fontSize: 10),
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
