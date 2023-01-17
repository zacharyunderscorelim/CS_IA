import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:second_eye/main.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;

import 'dart:developer' as developer;

class DysScreen extends StatefulWidget {
  const DysScreen({Key key, this.changePage}) : super(key: key);
  final void Function(int) changePage;
  @override
  _DysScreenState createState() => _DysScreenState();
}

class _DysScreenState extends State<DysScreen> {
  File imageFile;
  Future _getFromGallery() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future _getFromCamera() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> OCR(img) async {
    String result = "";
    final textDetector = GoogleMlKit.vision.textDetector();
    final RecognisedText recognisedText = await textDetector.processImage(img);
    setState(() {
      String text = recognisedText.text;
      for (TextBlock block in recognisedText.blocks) {
        final String text = block.text;
        for (TextLine line in block.lines) {
          for (TextElement element in line.elements) {
            result += element.text + " ";
          }
        }
      }
      result += "\n\n";
    });
    developer.log("result:$result");
    return result;
  }

  Future toBytes() async {
    final bytes = await rootBundle.load('assets/placeholder.png');
    final Uint8List list = bytes.buffer.asUint8List();
    developer.log(bytes.toString());
    return list;
  }

  InputImageData getAssetData() {
    Size imageSize = Size(275, 183);
    InputImageData data = InputImageData(
      imageRotation: InputImageRotation.Rotation_0deg,
      size: imageSize,
    );
    return data;
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
                  child: imageFile == null
                      ? Image.asset("assets/placeholder.png")
                      : Image.file(
                          imageFile,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Container(
                height: 100,
                width: 600,
                child: FutureBuilder(
                    future: toBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return FutureBuilder<String>(
                            future: OCR(imageFile == null
                                ? InputImage.fromBytes(
                                    bytes: snapshot.data,
                                    inputImageData: getAssetData())
                                : InputImage.fromFile(imageFile)),
                            builder: (context, snapshot2) {
                              if (snapshot2.hasData && snapshot2.data != "") {
                                developer.log("data: ${snapshot2.data}");
                                return Text((snapshot2.data).toString(),
                                    style: TextStyle(
                                        fontSize: themeProvider.font));
                              } else {
                                return Text("Loading");
                              }
                            });
                      } else {
                        return Text("Loading");
                      }
                    }),
                alignment: Alignment.center,
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
