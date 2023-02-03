import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:second_eye/Styles.dart';
import 'package:second_eye/colourPage.dart';
import 'package:second_eye/dysPage.dart';
import 'package:second_eye/settings.dart';
import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences.setMockInitialValues({});
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
    )
  ], child: const MyApp(title: 'Second Eye')));
}

class ThemeProvider with ChangeNotifier {
  //creation of a class ThemeProvider to notify the app when the theme and font size changes
  ThemePrefs themePrefs = ThemePrefs();
  FontPrefs fontPrefs = FontPrefs();
  bool _dark = false;
  double _font = 16;
  //initial values for the theme and font size

  bool get darkTheme {
    return _dark;
  }

  double get font {
    return _font;
  }
  //getters for the theme and font size

  set darkTheme(bool value) {
    if (value == null) {
      throw new ArgumentError();
    }
    _dark = value;
  }

  set font(double value) {
    if (value == null) {
      throw new ArgumentError();
    }
    _font = value;
  }
  //setters for the theme and font size

  setDarkmode(bool value) {
    _dark = value;
    themePrefs.setDark(value);
    notifyListeners();
  }

  setFont(double value) {
    _font = value;
    fontPrefs.setFont(value);
    notifyListeners();
  }
  //notifying the app when the theme and font size changes
}

class ThemePrefs {
  static const THEME_STATUS = "THEMESTATUS";

  setDark(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_STATUS, value);
  }
  //making sure the theme is saved in the shared preferences

  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_STATUS) ?? false;
  }
  //getting the theme from the shared preferences
}

class FontPrefs {
  static const FONT_SIZE = "FONTSIZE";

  setFont(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble(FONT_SIZE, value);
  }
  //making sure the font size is saved in the shared preferences

  Future<double> getFont() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(FONT_SIZE) ?? 16;
  }
  //getting the font size from the shared preferences
}

class MyApp extends StatefulWidget {
  const MyApp({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Widget> _pages;
  Widget _page2;
  Widget _page3;
  Widget _page4;
  int _currentIndex;
  Widget _currentPage;

  ThemeProvider themeChangeProvider = new ThemeProvider();

  @override
  void initState() {
    //initialising the app
    super.initState();
    getCurrentAppTheme();
    //getting the current theme
    _page2 = ColourScreen(changePage: _changeTab);
    _page3 = DysScreen(changePage: _changeTab);
    _page4 = SettingsPage(changePage: _changeTab);
    _pages = [_page2, _page3, _page4];
    _currentIndex = 0;
    _currentPage = _page2;
    //initialising the different pages and the current page as the colourblind tool
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.themePrefs.getTheme();
    //getting the current theme from the shared preferences
  }

  void _changeTab(int index) {
    //changing the current page to another one
    setState(() {
      _currentIndex = index;
      _currentPage = _pages[index];
      developer.log("Current index: $_currentIndex");
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return ThemeProvider();
      },
      child: Consumer<ThemeProvider>(
          builder: (BuildContext context, value, Widget child) {
        return MaterialApp(
            theme: Styles.themeData(themeChangeProvider.darkTheme, context),
            //setting overall app theme to dark or light based on the current theme variable
            home: Scaffold(
              body: _currentPage,
              bottomNavigationBar: BottomNavigationBar(
                  //creation of a bottom navigation bar
                  currentIndex: _currentIndex,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.grey,
                  backgroundColor: Colors.black,
                  onTap: (index) {
                    _changeTab(index);
                  },
                  //changing the current page when a button on the navigation bar is pressed
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(Icons.color_lens_rounded),
                        label: "CVD Helper"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.abc_rounded), label: "Dyslexia"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.settings_rounded), label: "Settings"),
                  ]),
              //labels of the buttons on the navigation bar
              drawer: Drawer(
                child: Container(
                  margin: const EdgeInsets.only(top: 0.0),
                  child: Column(
                    children: <Widget>[
                      _navigationItemListTitle("CVD Helper", 0),
                      _navigationItemListTitle("Dyslexia", 1),
                      _navigationItemListTitle("Settings", 2)
                    ],
                  ),
                ),
              ),
            ));
      }),
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
final screens = [ColourScreen, DysScreen, DysScreen];
int screenindex = 0;

Future<void> gayNotif(var ctx) async {
  //notification for function
  HapticFeedback.vibrate();
  //vibrate
  return showDialog(
      //create dialog box
      context: ctx,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("OCR complete"),
          content: const Text("The text will be displayed"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
              //button to close the dialog box
            )
          ],
        );
      });
}
