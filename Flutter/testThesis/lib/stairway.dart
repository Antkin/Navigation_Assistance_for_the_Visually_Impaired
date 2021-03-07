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
import 'package:testThesis/stairway_camera.dart';

class Stairway extends StatefulWidget {
  final List<CameraDescription> cameras;
  int value;

  Stairway(this.cameras, this.value);

  @override
  _StairwayState createState() => new _StairwayState(value);
}

class _StairwayState extends State<Stairway> {
  _StairwayState(this.value);
  int value;
  String _model = "assets/yolov2_graph.lite";

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
            model: "assets/yolov2_graph.lite",
            labels: "assets/label.txt",
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
                    title: const Text('Stairway Classification!'))),

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
                      Column(children: <Widget>[StairwayCamera(widget.cameras, _model, value),
                      ]),
                    ],
                  )),
            ])));
  }
}
