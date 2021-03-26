import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'package:flutter_text_to_speech/flutter_text_to_speech.dart';
import 'dart:io';
import "dart:async";
import 'package:all_sensors/all_sensors.dart';
import 'package:flutter/services.dart';
import 'camera.dart';
import 'render.dart';
import 'package:testThesis/bus_shelter_camera.dart';
import 'package:testThesis/bounding_box.dart';

class BusShelter extends StatefulWidget {
  final List<CameraDescription> cameras;
  int value;

  BusShelter(this.cameras, this.value);

  @override
  _BusShelterState createState() => new _BusShelterState(value);
}

class _BusShelterState extends State<BusShelter> {
  _BusShelterState(this.value);
  int value;
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "assets/yolov2_bs.lite";

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadModel() async {
    try{
      String res;

      switch (_model) {
        default:
          res = await Tflite.loadModel(
            model: "assets/yolov2_bs.lite",
            labels: "assets/labels_bs.txt",
          );

          break;
      }
      print("Result is $res");
    }
    on PlatformException{
      print("Failed to load model.");
    }
  }

  onSelect(model){
    Future.delayed(Duration(seconds: 8), () {
      setState(() {
        _model = model;
      });
      loadModel();
    });
  }

  buildBusShelterBox(recognitions, imageHeight, imageWidth){
    if (!mounted){
      return;
    }

    setState((){
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  void release() async {
    await Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;

    return Container(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(20.0),
          child: AppBar(
            centerTitle: true,
            title: const Text('Bus Shelter Classification!'))),

        body: Column(children: <Widget> [
          RaisedButton(
            onPressed: (){
              setState(() {
                Navigator.pop(context);
              });
            },
            child: Text("Stop")),
          Expanded(
            child: Stack(
              children: [
                Column(children: <Widget>[BusShelterCamera(widget.cameras, _model, buildBusShelterBox, value),
                ]),
                BoundingBox(
                  _recognitions,
                  math.max(_imageHeight, _imageWidth),
                  math.min(_imageHeight, _imageWidth),
                  screen.height,
                  screen.width,
                ),
              ],
            )),
        ])));
  }
}
