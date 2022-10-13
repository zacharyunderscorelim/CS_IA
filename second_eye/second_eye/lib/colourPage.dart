import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:second_eye/dysPage.dart';
import 'main.dart';
import 'package:image_pixels/image_pixels.dart';

class ColourScreen extends StatefulWidget {
  const ColourScreen({Key? key, required this.changePage}) : super(key: key);
  final void Function(int) changePage;

  @override
  _ColourScreenState createState() => _ColourScreenState();
}

class _ColourScreenState extends State<ColourScreen> {
  File? imageFile;
  Offset localPosition = const Offset(-1, -1);
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

  Future ColourDetection() async {}

  @override
  Widget build(BuildContext context) {
    screenindex = 1;
    return MaterialApp(
      home: Scaffold(
        body: Container(
          child: Column(
            children: [
              SizedBox(height: 50),
              Container(
                  height: 400,
                  width: 600,

                  // adding listener to the image
                  child: Listener(
                    onPointerMove: (PointerMoveEvent details) {
                      setState(() {
                        localPosition = details.localPosition;
                      });
                    },
                    onPointerDown: (PointerDownEvent details) {
                      setState(() {
                        localPosition = details.localPosition;
                      });
                    },
                    child: ImagePixels(
                      imageProvider: FileImage(imageFile == null
                          ? File('assets/placeholder.png')
                          : imageFile!),
                      builder: (BuildContext context, ImgDetails img) {
                        var color = img.pixelColorAt!(
                          localPosition.dx.toInt(),
                          localPosition.dy.toInt(),
                        );
                        if (imageFile == null) {
                          return const SizedBox(
                              width: 150,
                              height: 213,
                              child: Image(
                                  image: AssetImage('assets/placeholder.png')));
                        }
                      },
                    ),
                  )),
              Container(
                height: 100,
                width: 600,
                child: RichText(
                  text: const TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: 'Selected Colour: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                    TextSpan(
                        text: 'not programmed yet',
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black)),
                  ]),
                ),
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
                      // Upload colour button
                      height: double.infinity,
                      width: 70,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.new_label_rounded),
                        iconSize: 70,
                        onPressed: () {},
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
