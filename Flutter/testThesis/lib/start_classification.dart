import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:testThesis/drawer_for_page.dart';
import 'package:testThesis/globals.dart';
import 'package:testThesis/home.dart';
import 'package:testThesis/bus_shelter.dart';
import 'package:testThesis/stairway.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'package:flutter_text_to_speech/flutter_text_to_speech.dart';
import 'dart:io';
import "dart:async";
import 'package:all_sensors/all_sensors.dart';
import 'package:flutter/services.dart';
import 'camera.dart';
import 'render.dart';
import 'dart:math' as math;
import 'package:testThesis/globals.dart';

class StartClassification extends StatefulWidget {
  final List<CameraDescription> cameras;
  String value;

  StartClassification(this.cameras, this.value);
  StartClassificationState createState() =>
      new StartClassificationState(cameras, value);
}

class StartClassificationState extends State<StartClassification> {
  final List<CameraDescription> cameras;
  String value;
  int values;
  StartClassificationState(this.cameras, this.value);
  VoiceController _voiceController;
  String text = "Indicates you should rotate right";
  String text_right = "Indicates you should rotate left";
  String _unknown =
      "Indicates there is obstruction ahead. Rotate away from the auditory cues as slowly as possible, if no sound is produced, it means you are correctly oriented";
  String textRotate = "Please begin slowly rotating while I determine " +
      "the correct heading.";

  var flutterTts = FlutterTts();
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";
  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  double rotationSpeed;
  bool _proximityValues = false;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  Future<void> _playVoice() {
    //
    return _voiceController.init().then((_) {
      audioCache.play("continual.wav");
      Future.delayed(const Duration(milliseconds: 1000), () {
        _voiceController.speak(
          text,
          VoiceControllerOptions(),
        );
      });
      Future.delayed(const Duration(seconds: 3), () {
        _voiceController.init().then((_) {
          audioCache.play("continual_right.wav");
          Future.delayed(const Duration(milliseconds: 1000), () {
            advancedPlayer.stop();
            _voiceController.speak(
              text_right,
              VoiceControllerOptions(),
            );
          });
        });
      });
      Future.delayed(const Duration(seconds: 6), () {
        _voiceController.init().then((_) {
          audioCache.play("unknown.wav");
          Future.delayed(const Duration(milliseconds: 1000), () {
            advancedPlayer.stop();
            _voiceController.speak(
              _unknown,
              VoiceControllerOptions(),
            );
          });
        });
      });
    });
    //  });
  }

  Future<void> _playRotation() {
    _voiceController.init().then((_) {
      _voiceController.speak(
        textRotate,
        VoiceControllerOptions(),
      );
    });
  }

  int _counter = 0;
  int count;
  static const platform = const MethodChannel('samples.flutter.dev/battery');
  String _batteryLevel = 'Unknown battery level.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final double result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  void initState() {
    count = 0;
    super.initState();
    _voiceController = FlutterTextToSpeech.instance.voiceController();
    values = int.parse(value);
    //  _voiceControllerRotate = FlutterTextToSpeech.instance.voiceController();
  }

  @override
  void dispose() {
    super.dispose();
    _voiceController.stop();
    // _voiceControllerRotate.stop();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Container(
        //quarterTurns: 1,
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(40.0),
                child: AppBar(
                    centerTitle: true,
                    title: const Text('TFlite Real Time Classification'))),
            drawer: DrawerForPage(),
            body: Center(
                child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ButtonTheme(
                    child: RaisedButton(
                      child: Text(ssd, style: TextStyle(fontSize: 25.0)),
                      onPressed: count == 0
                          ? () {
                              count = 1;
                              //_playVoice();
                              _playRotation();
                              _getBatteryLevel();
                              print(Values.value);
                              // onSelect(ssd);
                              Future.delayed(Duration(seconds: 1), () {
                                _getBatteryLevel();
                                Future.delayed(Duration(seconds: 4), () {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomePage(cameras, values)))
                                      .whenComplete(() {
                                    setState(() {
                                      count = 0;
                                    });
                                  });
                                });
                                print(
                                    "The battery level is:                                 $_batteryLevel");
                              });
                            }
                          : null,
                    ),
                  ),
                  RaisedButton(
                      onPressed: () {
                        _playVoice();
                        print("value is: $values");
                      },
                      child: Text("Play Tutorial",
                          style: TextStyle(fontSize: 25.0))),
                  RaisedButton(
                      onPressed: () {
                        print("Bus Shelter detector!");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BusShelter(cameras, values)));
                      },
                      child: Text("Start Bus Shelter Detection",
                          style: TextStyle(fontSize: 25.0))),
                  RaisedButton(
                      onPressed: () {
                        print(" Stairway detector!");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Stairway(cameras, values)));
                        },
                      child: Text("Start Stairway Detection",
                          style: TextStyle(fontSize: 25.0)))
                ],
              ),
            ))));
  }
}
