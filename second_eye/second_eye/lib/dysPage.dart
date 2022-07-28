import 'package:flutter/material.dart';

class DysScreen extends StatefulWidget {
  const DysScreen({Key? key, required this.changePage}) : super(key: key);
  final void Function(int) changePage;
  @override
  _DysScreenState createState() => _DysScreenState();
}

class _DysScreenState extends State<DysScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                  child: Image.network(
                    'https://memezila.com/saveimage/Local-duck-receives-headpats-Look-how-happy-this-duck-is-meme-9988',
                    height: 150.0,
                    width: 150.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 100,
                width: 600,
                child: RichText(
                  text: const TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: 'Text:',
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
                        onPressed: () {},
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
