import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:second_eye/Styles.dart';
import 'package:second_eye/dysPage.dart';
import 'main.dart';
import 'package:image_pixels/image_pixels.dart';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
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
    if (paletteGenerator.dominantColor != null) {
      return paletteGenerator.dominantColor.color;
    } else {
      return Colors.white;
    }
  }

  Future<String> ColourDetection(var colour, var db) async {
    int R = colour.red;
    int G = colour.green;
    int B = colour.blue;

    int r, g, b = 0;
    double temp = 0.0;
    double min = 1000000.0;
    String closestColourId = "colour0";
    String closestColourName = " ";

    developer.log("RGB: $R, $G, $B");

    //it through the database and finds the closest colour
    final QuerySnapshot querySnapshot = await db.collection("colours").get();

    final allColours = querySnapshot.docs
        .map((doc) => doc.data() as Map<dynamic, dynamic>)
        .toList();

    print(allColours);
    for (int i = 0; i < allColours.length; i++) {
      r = allColours[i]["R"];
      g = allColours[i]["G"];
      b = allColours[i]["B"];
      double k = (R + r) / 2;
      temp = sqrt((2 + (k / 256)) * pow((r - R), 2) +
          4 * pow((g - G), 2) +
          (2 + ((255 - k) / 256)) * pow((b - B), 2));
      print("temp:" + temp.toString());
      if (temp < min) {
        min = temp;
        closestColourName = allColours[i]["name"];
      }
    }
    print("min:" + min.toString());
    print(closestColourName);
    return closestColourName.toString();
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

  Future<void> AddColour(var ctx, var colour, var db) async {
    String temp = "placeholder";
    return showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Add Colour'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  temp = value;
                });
              },
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
                child: FutureBuilder<Color>(
                  future: getImagePalette(imageFile == null
                      ? const AssetImage('assets/placeholder.png')
                      : FileImage(imageFile)),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      colour = snapshot.data;
                      return FutureBuilder<String>(
                        future: ColourDetection(colour, db),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              "Dominant Colour: " + snapshot.data,
                              style: TextStyle(
                                fontSize: themeProvider.font,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          } else {
                            return Text(
                              "Dominant Colour: white",
                              style: TextStyle(
                                fontSize: themeProvider.font,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                        },
                      );
                    } else {
                      return Text(
                        "Dominant Colour: white",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      );
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
 

/*
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;

class ColorPickerWidget extends StatefulWidget {
  @override
  _ColorPickerWidgetState createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  String imagePath = 'assets/images/santorini.jpg';
  GlobalKey imageKey = GlobalKey();
  GlobalKey paintKey = GlobalKey();

  // CHANGE THIS FLAG TO TEST BASIC IMAGE, AND SNAPSHOT.
  bool useSnapshot = true;

  // based on useSnapshot=true ? paintKey : imageKey ;
  // this key is used in this example to keep the code shorter.
  GlobalKey currentKey;

  final StreamController<Color> _stateController = StreamController<Color>();
  img.Image photo;

  @override
  void initState() {
    currentKey = useSnapshot ? paintKey : imageKey;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String title = useSnapshot ? "snapshot" : "basic";
    return Scaffold(
      appBar: AppBar(title: Text("Color picker $title")),
      body: StreamBuilder(
          initialData: Colors.green[500],
          stream: _stateController.stream,
          builder: (buildContext, snapshot) {
            Color selectedColor = snapshot.data ?? Colors.green;
            return Stack(
              children: <Widget>[
                RepaintBoundary(
                  key: paintKey,
                  child: GestureDetector(
                    onPanDown: (details) {
                      searchPixel(details.globalPosition);
                    },
                    onPanUpdate: (details) {
                      searchPixel(details.globalPosition);
                    },
                    child: Center(
                      child: Image.asset(
                        imagePath,
                        key: imageKey,
                        //color: Colors.red,
                        //colorBlendMode: BlendMode.hue,
                        //alignment: Alignment.bottomRight,
                        fit: BoxFit.none,
                        //scale: .8,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(70),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedColor,
                      border: Border.all(width: 2.0, color: Colors.white),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2))
                      ]),
                ),
                Positioned(
                  child: Text('${selectedColor}',
                      style: TextStyle(
                          color: Colors.white,
                          backgroundColor: Colors.black54)),
                  left: 114,
                  top: 95,
                ),
              ],
            );
          }),
    );
  }

  void searchPixel(Offset globalPosition) async {
    if (photo == null) {
      await (useSnapshot ? loadSnapshotBytes() : loadImageBundleBytes());
    }
    _calculatePixel(globalPosition);
  }

  void _calculatePixel(Offset globalPosition) {
    RenderBox box = currentKey.currentContext.findRenderObject();
    Offset localPosition = box.globalToLocal(globalPosition);

    double px = localPosition.dx;
    double py = localPosition.dy;

    if (!useSnapshot) {
      double widgetScale = box.size.width / photo.width;
      print(py);
      px = (px / widgetScale);
      py = (py / widgetScale);
    }

    int pixel32 = photo.getPixelSafe(px.toInt(), py.toInt());
    int hex = abgrToArgb(pixel32);

    _stateController.add(Color(hex));
  }

  Future<void> loadImageBundleBytes() async {
    ByteData imageBytes = await rootBundle.load(imagePath);
    setImageBytes(imageBytes);
  }

  Future<void> loadSnapshotBytes() async {
    RenderRepaintBoundary boxPaint = paintKey.currentContext.findRenderObject();
    ui.Image capture = await boxPaint.toImage();
    ByteData imageBytes =
        await capture.toByteData(format: ui.ImageByteFormat.png);
    setImageBytes(imageBytes);
    capture.dispose();
  }

  void setImageBytes(ByteData imageBytes) {
    List<int> values = imageBytes.buffer.asUint8List();
    photo = null;
    photo = img.decodeImage(values);
  }
}

// image lib uses uses KML color format, convert #AABBGGRR to regular #AARRGGBB
int abgrToArgb(int argbColor) {
  int r = (argbColor >> 16) & 0xFF;
  int b = argbColor & 0xFF;
  return (argbColor & 0xFF00FF00) | (b << 16) | r;
}
*/