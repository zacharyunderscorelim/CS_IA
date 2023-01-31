import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:second_eye/Styles.dart';
import 'main.dart';
import 'package:image_pixels/image_pixels.dart';
import 'dart:developer' as developer;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key key, this.changePage}) : super(key: key);
  final void Function(int) changePage;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  @override
  bool getThemeBoolean(var db) {
    DocumentReference docRef = db.collection("settings").doc("theme");
    docRef.get().then((DocumentSnapshot documentSnapshot) {
      return (documentSnapshot.data() as Map<dynamic, dynamic>)["light_theme"];
    });
  }

  Future<void> showHelpBox(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Help"),
            content: Text(
                "This is the settings page. Here you can change the theme of the app and the font size. At the bottom of the screen, there is a navigation bar. You can use this to navigate to the other pages of the app. The CVD page is where you can check the colour of an image, and the Dys page is where you can use OCR to read difficult to read text."),
            actions: <Widget>[
              TextButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  var db = FirebaseFirestore.instance;
  int fontSize = 16;
  var fontList = List<int>.generate(35, (i) => i + 1);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
        theme: Styles.themeData(themeProvider.darkTheme, context),
        home: Scaffold(
          appBar: AppBar(
            title: Text("Settings"),
          ),
          body: Center(
            child: Column(
              children: [
                SizedBox(height: 50),
                Container(
                  margin: EdgeInsets.all(12),
                  height: 50,
                  width: double.infinity,
                  child: const Text(
                    "Dark Theme:",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                    margin: EdgeInsets.all(12),
                    height: 50,
                    child: Checkbox(
                        value: themeProvider.darkTheme,
                        onChanged: (bool value) {
                          themeProvider.darkTheme = value;
                          setState(() {});
                        })),
                Container(
                  margin: EdgeInsets.all(12),
                  height: 50,
                  width: double.infinity,
                  child: const Text(
                    "Font size:",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                    margin: EdgeInsets.all(12),
                    alignment: Alignment.topLeft,
                    height: 50,
                    width: double.infinity,
                    child: DropdownButton<double>(
                      alignment: Alignment.topLeft,
                      value: themeProvider.font,
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (double value) {
                        themeProvider.font = value;
                        setState(() {});
                      },
                      items: fontList.map<DropdownMenuItem<double>>((value) {
                        return DropdownMenuItem<double>(
                          value: value.toDouble(),
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    )),
                Container(
                    margin: EdgeInsets.all(12),
                    height: 50,
                    width: double.infinity,
                    child: TextButton(
                      child: Text("help"),
                      // ignore: void_checks
                      onPressed: () {
                        return FutureBuilder<void>(
                            future: showHelpBox(context),
                            builder: (snapshot, context) {
                              return snapshot.widget;
                            });
                      },
                    ))
              ],
            ),
          ),
        ));
  }
}
