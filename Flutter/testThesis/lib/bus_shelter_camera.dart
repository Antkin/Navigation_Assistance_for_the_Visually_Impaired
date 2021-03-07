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

class BusShelterCamera extends StatefulWidget {
  final List<CameraDescription> cameras;
  int value;

  BusShelterCamera(this.cameras, this.value);

  @override
  _BusShelterCameraState createState() => new _BusShelterCameraState(value);
}

class _BusShelterCameraState extends State<BusShelterCamera> {
  _BusShelterCameraState(this.value);
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
          print("Image height is : ${img.height}");
          //isDetecting = true;
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

    return Container(
      child: CameraPreview(controller),
      constraints: BoxConstraints(
        maxHeight: 500,
        maxWidth: screenW,
      ),
    );
  }
}