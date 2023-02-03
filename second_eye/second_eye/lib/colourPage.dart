import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:second_eye/Styles.dart';
import 'package:second_eye/dysPage.dart';
import 'main.dart';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter/services.dart';

class ColourScreen extends StatefulWidget {
  const ColourScreen({Key key, this.changePage}) : super(key: key);
  final void Function(int) changePage;

  @override
  _ColourScreenState createState() => _ColourScreenState();
}

class _ColourScreenState extends State<ColourScreen> {
  TextEditingController _textController = TextEditingController();

  Future<Color> getImagePalette(ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);
    //calling the PaletteGenerator fromImageProvider to generate a colour palette of the image
    if (paletteGenerator.dominantColor != null) {
      return paletteGenerator.dominantColor.color;
      //returning the dominant colour of the image
    } else {
      return Colors.white;
    }
  }

  Future<String> ColourDetection(var colour, var db) async {
    int R = colour.red;
    int G = colour.green;
    int B = colour.blue;
    //getting the RGB values of the dominant colour

    int r, g, b = 0;
    double temp = 0.0;
    double min = 1000000.0;
    String closestColourId = "colour0";
    String closestColourName = " ";
    //initialising variables

    developer.log("RGB: $R, $G, $B");

    //it through the database and finds the closest colour
    final QuerySnapshot querySnapshot = await db.collection("colours").get();
    //getting all the colours from the database

    final allColours = querySnapshot.docs
        .map((doc) => doc.data() as Map<dynamic, dynamic>)
        .toList();
    //converting the query snapshot to a list of maps

    for (int i = 0; i < allColours.length; i++) {
      //looping through the list of maps
      r = allColours[i]["R"];
      g = allColours[i]["G"];
      b = allColours[i]["B"];
      //getting the RGB values of the current iterated colour in the database
      double k = (R + r) / 2;
      //calculating the value of k
      temp = sqrt((2 + (k / 256)) * pow((r - R), 2) +
          4 * pow((g - G), 2) +
          (2 + ((255 - k) / 256)) * pow((b - B), 2));
      //calculating the distance between the dominant colour and the current iterated colour in the database

      if (temp < min) {
        min = temp;
        closestColourName = allColours[i]["name"];
        //updating the closest colour name and the minimum distance
      }
    }
    return closestColourName.toString();
    //returning the closest colour name
  }

  var db = FirebaseFirestore.instance;
  Color colour = Colors.white;
  File imageFile;

  Future _getFromGallery() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    //getting the image from the gallery
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
    //setting the image file to the image picked from the gallery
  }

  Future _getFromCamera() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    //getting the image from the camera
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
    //setting the image file to the image picked from the camera
  }

  Future<void> AddColour(var ctx, var colour, var db) async {
    String temp = "placeholder";
    //initialising a temporary string variable
    return showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            //creating an alert dialog
            title: const Text('Add Colour'),
            //setting the title of the alert dialog
            content: TextField(
              onChanged: (value) {
                setState(() {
                  temp = value;
                });
              },
              //getting the name of the colour from the user
              controller: _textController,
              decoration: InputDecoration(hintText: "Enter Colour Name"),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              //creating a cancel button
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    db.collection("colours").add({
                      "name": temp,
                      "R": colour.red,
                      "G": colour.green,
                      "B": colour.blue,
                    });
                    Navigator.pop(context);
                  });
                },
              ),
              //creating an ok button
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      theme: Styles.themeData(themeProvider.darkTheme, context),
      home: Scaffold(
        body: Container(
          child: Column(
            children: [
              SizedBox(height: 50),
              Container(
                height: 400,
                width: 600,
                //height and width of the image container
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: imageFile == null
                      ? Image.asset("assets/placeholder.png")
                      //displaying a placeholder image when image is not uploaded
                      : Image.file(
                          imageFile,
                          fit: BoxFit.cover,
                        ),
                  //displaying the image from upload/camera
                ),
              ),
              Container(
                height: 100,
                width: 600,
                child: FutureBuilder<Color>(
                  future: getImagePalette(imageFile == null
                          ? const AssetImage('assets/placeholder.png')
                          //gets the dominant colour of the placeholder image when image is not uploaded
                          : FileImage(imageFile)
                      //gets the dominant colour of the image from upload/camera
                      ),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      colour = snapshot.data;
                      return FutureBuilder<String>(
                        future: ColourDetection(colour, db),
                        //calls the colour name detection function on the dominant colour's RGB values
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              "Dominant Colour: " + snapshot.data,
                              style: TextStyle(
                                fontSize: themeProvider.font,
                                fontWeight: FontWeight.bold,
                              ),
                              //displays the dominant colour's name
                            );
                          } else {
                            return Text(
                              "Dominant Colour: white",
                              style: TextStyle(
                                fontSize: themeProvider.font,
                                fontWeight: FontWeight.bold,
                              ),
                              //displays "white" when dominant colour is not detected
                            );
                          }
                        },
                      );
                    } else {
                      return const Text(
                        "Dominant Colour: white",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                      //displays "white" by default
                    }
                  },
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
                          HapticFeedback.mediumImpact();
                        },
                        //button to open gallery and upload image
                      ),
                    ),
                    Container(
                      //upload new colour button
                      height: double.infinity,
                      width: 70,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        iconSize: 70,
                        onPressed: () {
                          AddColour(context, colour, db);
                        },
                        //button to add new colour to the database
                      ),
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
                          HapticFeedback.mediumImpact();
                        },
                        //button to open camera and upload image
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
