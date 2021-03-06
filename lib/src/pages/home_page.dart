import 'dart:io' show Platform;
import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera_camera/page/camera.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_poc/src/pages/flutter_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_startup/flutter_startup.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import '../../widgets.dart';

enum _Platform { android, ios }

void isolate2(String arg) {
  FlutterStartup.startupReason.then((reason) {
    print("Isolate2 $reason");
  });
  Timer.periodic(
      Duration(seconds: 1), (timer) => print("Timer Running From Isolate 2"));
}

void isolate1(String arg) async {
  FlutterStartup.startupReason.then((reason) {
    print("Isolate1 $reason");
  });
  Timer.periodic(Duration(seconds: 10), (timer) => {print('salami')});
}

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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final appTitle = 'Revilion Poc';
  File val;
  String _sharingState = 'Awaiting Sharing';
  String _beaconResult = 'Not Scanned Yet.';
  int _nrMessaggesReceived = 0;
  var isRunning = false;
  bool isInForeground = true;
  bool _showNotification = false;

  final StreamController<String> beaconEventsController =
      StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    isInForeground = state == AppLifecycleState.resumed;
    final isolate = await FlutterIsolate.spawn(isolate1, "hello");
    if (isInForeground == false) {
      FlutterBlue.instance.startScan(timeout: Duration(seconds: 60000));

// Listen to scan results
      FlutterBlue.instance.scanResults.listen((results) {
        // do something with scan results
        for (ScanResult r in results) {
          if (r.device.id.toString() == "EA:F0:0B:05:5A:84") {
            setState(() {
              _showNotification = true;
            });
            print('motherfucker');
          }
        }
      });
      isolate.resume();
    } else {
      FlutterBlue.instance.stopScan();
      isolate.pause();
    }
    print("isInForeground: " + isInForeground.toString());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    beaconEventsController.close();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    if (Platform.isAndroid) {
      //Prominent disclosure
      await BeaconsPlugin.setDisclosureDialogMessage(
          title: "Need Location Permission",
          message: "This app collects location data to work with beacons.");

      //Only in case, you want the dialog to be shown again. By Default, dialog will never be shown if permissions are granted.
      //await BeaconsPlugin.clearDisclosureDialogShowFlag(false);
    }

    BeaconsPlugin.listenToBeacons(beaconEventsController);

    await BeaconsPlugin.addRegion(
        "BeaconType1", "909c3cf9-fc5c-4841-b695-380958a51a5a");
    await BeaconsPlugin.addRegion(
        "BeaconType2", "6a84c716-0f2a-1ce9-f210-6a63bd873dd9");

    beaconEventsController.stream.listen(
        (data) {
          if (data.isNotEmpty) {
            setState(() {
              _beaconResult = data;
              _nrMessaggesReceived++;
            });
            Map<String, dynamic> user = jsonDecode(data);
            // var str = json.encode(dat);
            // print(dat);
            // print(str);
            if (user['uuid'] == '2A38F000-59C8-492B-9358-0E4E38FB0054') {
              print(user['uuid']);
            } else {
              print("Beacons DataReceived: " + data);
            }
          }
        },
        onDone: () {},
        onError: (error) {
          // print("Error: $error");
        });

    //Send 'true' to run in background
    await BeaconsPlugin.runInBackground(true);

    if (Platform.isAndroid) {
      BeaconsPlugin.channel.setMethodCallHandler((call) async {
        if (call.method == 'scannerReady') {
          await BeaconsPlugin.startMonitoring;
          setState(() {
            isRunning = true;
          });
        }
      });
    } else if (Platform.isIOS) {
      await BeaconsPlugin.startMonitoring;
      setState(() {
        isRunning = true;
      });
    }

    if (!mounted) return;
  }

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
        body: PageView(children: [
          Scaffold(
              floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.camera_alt),
                  onPressed: () async {
                    val = await showDialog(
                        context: context,
                        builder: (context) => Camera(
                              mode: CameraMode.fullscreen,
                              initialCamera: CameraSide.front,
                              enableCameraChange: true,
                              orientationEnablePhoto:
                                  CameraOrientation.landscape,
                              onChangeCamera: (direction, _) {
                                // print('--------------');
                                // print('$direction');
                                // print('--------------');
                              },
                              // imageMask: widget,
                            ));
                    setState(() {});
                  }),
              body: Container(
                margin: new EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                        child:
                            Text(_sharingState, style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ],
                ),
              )

              // margin: const EdgeInsets.all(40.0),
              // Center is a layout widget. It takrs a single child and positions it
              // in the middle of the parent.
              ),
          FlutterBlueApp(),
          NotificationPage(isInForeground),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('$_beaconResult'),
                Padding(
                  padding: EdgeInsets.all(10.0),
                ),
                Text('$_nrMessaggesReceived'),
                SizedBox(
                  height: 20.0,
                ),
                Visibility(
                  visible: isRunning,
                  child: RaisedButton(
                    onPressed: () async {
                      if (Platform.isAndroid) {
                        await BeaconsPlugin.stopMonitoring;

                        setState(() {
                          isRunning = false;
                        });
                      }
                    },
                    child:
                        Text('Stop Scanning', style: TextStyle(fontSize: 20)),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Visibility(
                  visible: !isRunning,
                  child: RaisedButton(
                    onPressed: () async {
                      initPlatformState();
                      await BeaconsPlugin.startMonitoring;

                      setState(() {
                        isRunning = true;
                      });
                    },
                    child:
                        Text('Start Scanning', style: TextStyle(fontSize: 20)),
                  ),
                )
              ],
            ),
          ),
        ])

        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}

class FlutterBlueApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            // print(state);
            if (state == BluetoothState.on) {
              return FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class IosPlatform extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    final String viewType = 'iosView';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};

    return UiKitView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .map((d) => ListTile(
                            title: Text(d.name),
                            subtitle: Text(d.id.toString()),
                            trailing: StreamBuilder<BluetoothDeviceState>(
                              stream: d.state,
                              initialData: BluetoothDeviceState.disconnected,
                              builder: (c, snapshot) {
                                if (snapshot.data ==
                                    BluetoothDeviceState.connected) {
                                  return RaisedButton(
                                    child: Text('OPEN'),
                                    onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DeviceScreen(device: d))),
                                  );
                                }
                                return Text(snapshot.data.toString());
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .map(
                        (r) => ScanResultTile(
                          result: r,
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            r.device.connect();
                            return DeviceScreen(device: r.device);
                          })),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 8)));
          }
        },
      ),
    );
  }
}

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  List<int> _getRandomBytes() {
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map(
                  (c) => CharacteristicTile(
                    characteristic: c,
                    onReadPressed: () => c.read(),
                    onWritePressed: () async {
                      await c.write(_getRandomBytes(), withoutResponse: true);
                      await c.read();
                    },
                    onNotificationPressed: () async {
                      await c.setNotifyValue(!c.isNotifying);
                      await c.read();
                    },
                    descriptorTiles: c.descriptors
                        .map(
                          (d) => DescriptorTile(
                            descriptor: d,
                            onReadPressed: () => d.read(),
                            onWritePressed: () => d.write(_getRandomBytes()),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return FlatButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        .copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: (snapshot.data == BluetoothDeviceState.connected)
                    ? Icon(Icons.bluetooth_connected)
                    : Icon(Icons.bluetooth_disabled),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data ? 1 : 0,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () => device.discoverServices(),
                      ),
                      IconButton(
                        icon: SizedBox(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                          ),
                          width: 18.0,
                          height: 18.0,
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
            StreamBuilder<int>(
              stream: device.mtu,
              initialData: 0,
              builder: (c, snapshot) => ListTile(
                title: Text('MTU Size'),
                subtitle: Text('${snapshot.data} bytes'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => device.requestMtu(223),
                ),
              ),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: [],
              builder: (c, snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  File val;
  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return Form(
        key: _formKey,
        child: Column(children: <Widget>[
          TextFormField(
            decoration: new InputDecoration(labelText: "Enter your number"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
          ),
          SizedBox(height: 10),
          TextFormField(
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              if (!regex.hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              // Validate returns true if the form is valid, otherwise false.
              if (_formKey.currentState.validate()) {
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Processing Data')));
              }
            },
            child: Text('Submit'),
          ),
          // Add TextFormFields and ElevatedButton here.
        ]));
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// class PlatformEnabledButton extends RaisedButton {
//   final _Platform platform;

//   PlatformEnabledButton({
//     this.platform,
//     @required Widget child,
//     @required VoidCallback onPressed,
//   })  : assert(child != null, onPressed != null),
//         super(
//             child: child,
//             onPressed: (Platform.isAndroid && platform == _Platform.android ||
//                     Platform.isIOS && platform == _Platform.ios)
//                 ? onPressed
//                 : null);
// }
