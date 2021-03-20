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

var now = new List();
var sub = new List();
int useModelCounter = 0;
int totalCount = 10;
int temp;
var map2 = Map();
var map1 = Map();
typedef void Callback(List<dynamic> list, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;

  final Callback setRecognitions;
  final String model;
  int value;

  Camera(this.cameras, this.model, this.setRecognitions, this.value);

  @override
  _CameraState createState() => new _CameraState(value);
}

double xt_pred = 4.0;
double pt_pred = 0.8;
double K_pred = 0.0;
double Q_pred = 0.01;
double R_meas_pred = 0.8;
double xt = 0.0;
double pt = 0.5;
double K = 0.0;
double Q = 0.01;
double R_meas = 1.0;
int kalmanUnknownCounter = 0;
int flag = 0;
var _temp;
String text = "Rotate Slower ";
String text_orientation =
    "Correct heading determined, when you know it is safe begin " + "Crossing.";

class _CameraState extends State<Camera> {
  _CameraState(this.value);
  CameraController controller;
  bool isDetecting = false;
  AudioCache audioCache = AudioCache();
  AudioPlayer advancedPlayer = AudioPlayer();
  VoiceController _voiceController;
  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  double rotationSpeed;
  bool _proximityValues = false;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  int value;
  int _counter = 0;

  static const platform = const MethodChannel('samples.flutter.dev/battery');
  String _batteryLevel = 'Unknown battery level.';
  double _mX = 0.0;
  double mInitX = 0.0;
  int mPrediction = 0;
  int deviationAmount;
  int obtainPredictionFromAngles() {
    mPrediction = 0;
    double value = (_mX - mInitX).abs();
    if (((_mX - mInitX).abs() > 3.0) && ((_mX - mInitX).abs() < 8.0)) {
      deviationAmount = 1;
    } else if (((_mX - mInitX).abs() > 8.0) && ((_mX - mInitX).abs() < 12.0)) {
      deviationAmount = 2;
    } else if ((_mX - mInitX).abs() > 12.0) {
      deviationAmount = 3;
    } else {
      deviationAmount = 0;
    }

    if (_mX - mInitX < 0.0) {
      mPrediction = mPrediction + deviationAmount;
    } else {
      mPrediction = mPrediction - deviationAmount;
    }
    print("$value");
    print("prediction for gyro $mPrediction");
    return mPrediction;
  }

  double applyKalmanFilterForPrediction(double predictedValue) {
    if (predictedValue != 0.0) {
      pt_pred = pt_pred + Q_pred;
      K_pred = pt_pred / (pt_pred + R_meas_pred);
      xt_pred = xt_pred + K_pred * (predictedValue - xt_pred);
      pt_pred = pt_pred * (1.0 - K_pred);
      kalmanUnknownCounter = 0;
    } else {
      kalmanUnknownCounter++;
    }

    if (kalmanUnknownCounter >= 3) {
      print("Kalman Filter for Prediction: Here, returning = 0");
      return 0;
    }

    return xt_pred.roundToDouble();
  }

  double applyKalmanFilterForAngle(double angle) {
    pt = pt + Q;
    K = pt / (pt + R_meas);
    xt = xt + K * (angle - xt);
    pt = pt * (1.0 - K);
    return xt;
  }

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    double result;
    try {
      result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      mInitX = result;
      //print("mInitX is: "+mInitX.toString());
    });
  }

  Future<void> _getBatteryLevelForMx() async {
    String batteryLevel;
    double result;
    try {
      result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _mX = result;
      //print("mX is: "+_mX.toString());
    });
  }

  @override
  void initState() {
    _counter = 0;
    flag = 0;
    useModelCounter = 0;
    print(
        "flag value is:                                                                                           $flag");
    super.initState();
    _voiceController = FlutterTextToSpeech.instance.voiceController();
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
        rotationSpeed = (_gyroscopeValues[0] * 180.0) / math.pi;
      });
    }));

    ///now = [0,0,0];
    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No camera is found');
    } else {
      controller = new CameraController(
        widget.cameras[0],
        ResolutionPreset.medium,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller.startImageStream((CameraImage img) {
          if (!isDetecting) {
            print("image height is : ${img.height}");
            isDetecting = true;

            int startTime = new DateTime.now().millisecondsSinceEpoch;

            Tflite.runModelOnFrame(
                    bytesList: img.planes.map((plane) {
                      return plane.bytes;
                    }).toList(),
                    imageHeight: img.height,
                    imageWidth: img.width,
                    imageMean: 127.5,
                    imageStd: 127.5,
                    numResults: 3,
                    rotation: 90,
                    threshold: 0.1)
                .then((recognitions) {
              recognitions.map((res) {});
              _temp = recognitions[0]["label"];
              _temp = double.parse(_temp);
              //print(applyKalmanFilterForPrediction(_temp));
              rotationSpeed = ((_gyroscopeValues[0] * 180.0) / math.pi).abs();
              //print("rotationspeed is: $rotationSpeed");
              if (!mounted){
                return;
              }
              setState(() {
                _getBatteryLevelForMx();
                // print(
                //     "On new page with battery level of :                $mInitX");
                // print("Count is :        $useModelCounter");
                if (_counter < value) {
                  _counter++;
                  print("counter value is $_counter");
                  // if (rotationSpeed > 30) {
                  //   _voiceController.init().then((_) {
                  //     _voiceController.speak(
                  //       text,
                  //       VoiceControllerOptions(),
                  //     );
                  //   });
                  // }
                }
                if (_counter >= value) {
                  _counter = 0;
                  if (useModelCounter < totalCount) {
                    // if (rotationSpeed > 30) {
                    //   _voiceController.init().then((_) {
                    //     _voiceController.speak(
                    //       text,
                    //       VoiceControllerOptions(),
                    //     );
                    //   });
                    // }

                    //_temp = 4;
                    if (_temp > 4 && _temp < 7 && flag == 1) {
                      audioCache.play("continual.wav");
                    } else if (_temp <= 3 && flag == 1) {
                      audioCache.play("continual_right.wav");
                    } else if (_temp == 7 && flag == 1) {
                      audioCache.play("unknown.wav");
                    } else if (_temp == 4) {
                      if (_temp == 4) {
                        useModelCounter++;
                        //useModelCounter = 0; // in order to use the model only for predictions
                      } else {
                        useModelCounter = 0;
                      }
                    }
                  }
                  if (useModelCounter >= totalCount) {
                    if (flag == 1) {
                      print(
                          "I am inside flag where flag is 1. Now ideally the correct heading determined should be played");
                      flag = 2;
                      _getBatteryLevel();
                      //_getBatteryLevelForMx();
                      _voiceController.init().then((_) {
                        _voiceController.speak(
                          text_orientation,
                          VoiceControllerOptions(),
                        );
                      });
                      Future.delayed(Duration(seconds: 2), () {});
                    } else if (flag == 2) {
                      print(
                          "I am inside where flag is 2. now the minitx sensor should be played and this noise os of minitx");
                      Future.delayed(Duration(seconds: 4), () {
                        flag = 3;
                        _getBatteryLevelForMx();
                        print("minitX value is :               $_mX");
                      });
                    } else if (flag == 3) {
                      print(
                          "I am inside where flag is 3. now the minitx sensor should be played and this noise os of minitx");
                      //_getBatteryLevelForMx();
                      _mX = applyKalmanFilterForAngle(_mX);
                      print("mX value is:  $_mX");
                      _temp = obtainPredictionFromAngles();
                      if (_temp < 0) {
                        audioCache.play("continual.wav");
                      } else if (_temp > 0) {
                        audioCache.play("continual_right.wav");
                      }
                    }
                  }
                }
              });

              int endTime = new DateTime.now().millisecondsSinceEpoch;
              //print("Detection took ${endTime - startTime}");

              widget.setRecognitions(recognitions, img.height, img.width);

              isDetecting = false;
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    _voiceController.stop();
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }
    if (flag == 0) {
      flag = 1;
      _voiceController.speak(
        text,
        VoiceControllerOptions(),
      );
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
