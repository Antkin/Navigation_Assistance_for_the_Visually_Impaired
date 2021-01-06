import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:testThesis/start_classification.dart';

class ChangeValue extends StatefulWidget {
  @override
  ChangeValueState createState() => new ChangeValueState();
}

class ChangeValueState extends State<ChangeValue> {
  TextEditingController valueAdd = TextEditingController();
  List<CameraDescription> cameras;
  void findcameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      cameras = await availableCameras();
      print(cameras);
    } on CameraException catch (e) {
      print('Error: $e.code\nError Message: $e.message');
    }
  }

  void initState() {
    super.initState();
    //_voiceController = FlutterTextToSpeech.instance.voiceController();
    findcameras();
    //  _voiceControllerRotate = FlutterTextToSpeech.instance.voiceController();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Modify Prediction Rate"),
      ),
      body: Center(
          child: Column(children: <Widget>[
        Container(
          child: TextField(
              controller: valueAdd,
              decoration: InputDecoration(hintText: "Enter the value")),
        ),
        RaisedButton(
            child: Text("Set Value"),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          StartClassification(cameras, valueAdd.text)));
              //child: Text("Save value");
            })
      ])),
    );
  }
}
