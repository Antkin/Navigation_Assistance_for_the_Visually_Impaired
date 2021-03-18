import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_text_to_speech/flutter_text_to_speech.dart';
import 'dart:math' as math;
import 'package:all_sensors/all_sensors.dart';
import 'package:flutter/services.dart';
import "dart:async";

typedef void Callback(List<dynamic> list, int h, int w);

class StairwayCamera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback buildStairwayBox;
  final String model;
  int value;

  StairwayCamera(this.cameras, this.model, this.buildStairwayBox, this.value);

  @override
  _StairwayCameraState createState() => new _StairwayCameraState(value);
}

class _StairwayCameraState extends State<StairwayCamera> {
  _StairwayCameraState(this.value);
  CameraController controller;
  int value;
  bool isDetecting = false;


  @override
  void initState() {
    super.initState();

    if(widget.cameras != null || widget.cameras.length >= 1) {
      controller = new CameraController(
        widget.cameras[0],
        ResolutionPreset.medium,
      );
    }
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});

      controller.startImageStream((CameraImage img) {
        if (!isDetecting){
          //print("Image height is : ${img.height}");
          isDetecting = true;

          int startTime = new DateTime.now().millisecondsSinceEpoch;

          Tflite.detectObjectOnFrame(
            bytesList: img.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            model: "YOLO",
            numResultsPerClass: 1,
            imageHeight: img.height,
            imageWidth: img.width,
            imageMean: 127.5,
            imageStd: 127.5,
            rotation: 90,
            threshold:0.1)
          .then((recognitions) {
            recognitions.map((res) {});

            int endTime = new DateTime.now().millisecondsSinceEpoch;
            //print("DETECTED: $recognitions");
            widget.buildStairwayBox(recognitions, img.height, img.width); //This updates the labels in the screen on the app
            isDetecting = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized){
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize;
    //Screen height was previously 500, changed it to maintain same ratio as input images
    var screenH = screenW * (4/3);

    return Container(
      child: CameraPreview(controller),
      constraints: BoxConstraints(
        maxHeight: screenH,
        maxWidth: screenW,
      ),
    );
  }
}