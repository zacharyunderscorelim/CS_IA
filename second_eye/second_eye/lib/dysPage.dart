import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:second_eye/main.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:http/http.dart' as http;
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

import 'dart:developer' as developer;

class DysScreen extends StatefulWidget {
  const DysScreen({Key key, this.changePage}) : super(key: key);
  final void Function(int) changePage;
  @override
  _DysScreenState createState() => _DysScreenState();
}

class _DysScreenState extends State<DysScreen> {
  var image;
  String parsedText = "";
  bool loading = true;

  Future _getFromGallery() async {
    loading = true;
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        image = pickedFile;
        loading = false;
      });
    }
  }

  Future _getFromCamera() async {
    loading = true;
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        image = pickedFile;
        loading = false;
      });
    }
  }

  Future OCR(var image, var ctx) async {
    var path;
    var text;
    if (image == "assets/placeholder.png") {
      path = "assets/placeholder.png";
      text = "loading";
    } else {
      path = image.path;
      text = await FlutterTesseractOcr.extractText(path, language: "eng");
      await gayNotif(ctx);
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      theme: themeProvider.darkTheme ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        body: Container(
          child: Column(
            children: [
              SizedBox(height: 50),
              Container(
                height: 400,
                width: 600,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: image == null
                      ? Image.asset("assets/placeholder.png")
                      : Image.file(
                          File(image.path),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Container(
                height: 100,
                width: 600,
                child: FutureBuilder(
                  future: OCR(image == null ? "assets/placeholder.png" : image,
                      context),
                  builder: (context, snapshot2) {
                    if (snapshot2.hasData && snapshot2.data != "") {
                      developer.log("data: ${snapshot2.data}");
                      return Text((snapshot2.data).toString(),
                          style: TextStyle(fontSize: themeProvider.font));
                    } else {
                      return Text("Loading");
                    }
                  },
                ),
              ),
              Container(
                height: 100,
                width: 600,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      // Upload image button
                      height: double.infinity,
                      width: 70,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.upload_file_rounded),
                        iconSize: 70,
                        onPressed: () {
                          _getFromGallery();
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 45,
                    ),
                    Container(
                      // Upload camera image button
                      height: double.infinity,
                      width: 70,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.camera_alt_rounded),
                        iconSize: 70,
                        onPressed: () {
                          _getFromCamera();
                        },
                      ),
                    ),
                  ],
                ),
                alignment: Alignment.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
