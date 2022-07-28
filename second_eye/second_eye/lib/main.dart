import 'package:flutter/material.dart';
import 'package:second_eye/colourPage.dart';
import 'package:second_eye/dysPage.dart';
import 'globals.dart' as globals;

void main() {
  runApp(
    MaterialApp(
      home: MyApp(
        title: "Hello there",
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<Widget> _pages;
  late Widget _page1;
  late Widget _page2;
  late Widget _page3;
  late Widget _page4;
  late int _currentIndex;
  late Widget _currentPage;

  @override
  void initState() {
    super.initState();
    _page1 = ColourScreen(changePage: _changeTab);
    _page2 = ColourScreen(changePage: _changeTab);
    _page3 = DysScreen(changePage: _changeTab);
    _page4 = DysScreen(changePage: _changeTab);
    _pages = [_page1, _page2, _page3];
    _currentIndex = 0;
    _currentPage = _page1;
  }

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
      _currentPage = _pages[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPage,
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.black,
          onTap: (index) {
            _changeTab(index);
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.help_rounded), label: "Manual"),
            BottomNavigationBarItem(
                icon: Icon(Icons.color_lens_rounded), label: "CVD Helper"),
            BottomNavigationBarItem(
                icon: Icon(Icons.abc_rounded), label: "Dyslexia"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded), label: "Settings"),
          ]),
      drawer: Drawer(
        child: Container(
          margin: const EdgeInsets.only(top: 0.0),
          child: Column(
            children: <Widget>[
              _navigationItemListTitle("Manual", 0),
              _navigationItemListTitle("CVD Helper", 1),
              _navigationItemListTitle("Dyslexia", 2),
              _navigationItemListTitle("Settings", 3)
            ],
          ),
        ),
      ),
    );
  }

  Widget _navigationItemListTitle(String title, int index) {
    return ListTile(
      title: Text(
        '$title Page',
        style: TextStyle(color: Colors.blue[400], fontSize: 22.0),
      ),
      onTap: () {
        Navigator.pop(context);
        _changeTab(index);
      },
    );
  }
}

//globals
final screens = [ColourScreen, ColourScreen, DysScreen, DysScreen];
int screenindex = 0;
