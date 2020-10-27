import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
//import 'package:thesis/audio.dart';
import 'home.dart';

List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
    print(cameras);
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }

  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'tflite real-time classification',
        theme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: HomePage(cameras));
    //home: Audio(),
    //home: Scaffold(body: RaisedButton(onPressed: () {})));
  }
}
