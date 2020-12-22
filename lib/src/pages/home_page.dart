

import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera_camera/page/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

enum _Platform { android, ios }

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final appTitle = 'Revilion Poc';
  File val;

  String _sharingState = 'Awaiting Sharing';

  Future<void> _startSharing() async {
    String sharingState;
    try {
      await platform.invokeMethod('StartSharing');
      sharingState = 'Started Sharing';
    } on PlatformException catch (e) {
      sharingState = "Failed to start session: '${e.message}.";
    }

    setState(() {
      _sharingState = sharingState;
    });
  }

  static const platform = const MethodChannel('screenShare');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(appTitle),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.camera_alt),
          onPressed: () async {
            val = await showDialog(
                context: context,
                builder: (context) => Camera(
                      mode: CameraMode.fullscreen,
                      initialCamera: CameraSide.front,
                      enableCameraChange: true,
                      orientationEnablePhoto: CameraOrientation.landscape,
                      onChangeCamera: (direction, _) {
                        print('--------------');
                        print('$direction');
                        print('--------------');
                      },
                      // imageMask: widget,
                    ));
            setState(() {});
          }),
      body: Container(
        margin: new EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          // mainAxisAlignment: MainAxisAlignment.center
          children: <Widget>[
            // MyCustomForm(),
            // Expanded(
            //   child: IosPlatform(),
            // ),
            const SizedBox(height: 30),
            RaisedButton(
              onPressed: _startSharing,
              textColor: Colors.white,
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color(0xFF0D47A1),
                      Color(0xFF1976D2),
                      Color(0xFF42A5F5),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(10.0),
                child: Text(_sharingState, style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),

        // margin: const EdgeInsets.all(40.0),
        // Center is a layout widget. It takrs a single child and positions it
        // in the middle of the parent.
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}