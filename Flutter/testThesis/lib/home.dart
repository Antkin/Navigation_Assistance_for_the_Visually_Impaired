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
import 'dart:math' as math;

int useModelCounter = 0;
const String ssd = "Start Classification";
List<double> _gyroscopeValues;
List<StreamSubscription<dynamic>> _streamSubscriptions =
    <StreamSubscription<dynamic>>[];
AudioCache audioCache = AudioCache();
AudioPlayer advancedPlayer = AudioPlayer();

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomePage(this.cameras);
  //print(cameras);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  VoiceController _voiceController;
  String text = "Indicates you should rotate right";
  String text_right = "Indicates you should rotate left";
  String textRotate =
      "Rotate away from the auditory cues as slowly as possible, if no sound is produced, it means you are correctly oriented. Please begin slowly rotating while I determine " +
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

  @override
  void initState() {
    super.initState();
    _voiceController = FlutterTextToSpeech.instance.voiceController();
  }

  @override
  void dispose() {
    super.dispose();
    _voiceController.stop();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

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
    });
    //  });
  }

  _stopVoice() {
    _voiceController.stop();
  }

  loadModel() async {
    String res;

    switch (_model) {
      default:
        res = await Tflite.loadModel(
          model: "assets/mobilenet.tflite",
          labels: "assets/labels.txt",
        );

        break;
    }
    print(res);
  }

  Future<void> _playRotation() {
    Future.delayed(Duration(seconds: 7), () {
      _voiceController.speak(
        textRotate,
        VoiceControllerOptions(),
      );
    });
  }

  onSelect(model) {
    Future.delayed(Duration(seconds: 16), () {
      setState(() {
        _model = model;
      });
      loadModel();
    });
  }

  int _counter = 0;

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

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    // _getBatteryLevel();
    final List<String> gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();

    //final audioPosition = Provider.of<Duration>(context);
    Size screen = MediaQuery.of(context).size;

    return Container(
        //quarterTurns: 1,
        child: Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(20.0),
          child: AppBar(
              centerTitle: true,
              title: const Text('TFlite Real Time Classification'))),
      body: _model == ""
          ? Center(
              child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ButtonTheme(
                    child: RaisedButton(
                      child: Text(ssd, style: TextStyle(fontSize: 25.0)),
                      onPressed: () {
                        //_playVoice();
                        //_getBatteryLevel();
                        // _playVoice();
                        // _playRotation();
                        onSelect(ssd);
                        Future.delayed(Duration(seconds: 1), () {
                          _getBatteryLevel();
                          print(
                              "The battery level is:                                 $_batteryLevel");
                        });
                      },
                    ),
                  )
                ],
              ),
            ))
          : Stack(
              children: [
                // RotatedBox(
                //  quarterTurns: -1,
                Camera(
                  widget.cameras,
                  _model,
                  setRecognitions,
                ),
                Render(
                  _recognitions == null ? [] : _recognitions,
                  math.max(_imageHeight, _imageWidth),
                  math.min(_imageHeight, _imageWidth),
                  screen.height,
                  screen.width,
                ),
              ],
            ),
    ));
  }
}
