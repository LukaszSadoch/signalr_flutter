import 'package:flutter/material.dart';
import 'dart:async';
import 'package:signalr_flutter/signalr_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _signalRStatus = 'Unknown';
  SignalR signalR;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    signalR = SignalR(
        '<Your url here>', "<Your hubname here>",
        statusChangeCallback: _onStatusChange, hubCallback: _onNewMessage);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('SignalR Plugin Example App'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Connection Status: $_signalRStatus\n',
                  style: Theme.of(context).textTheme.headline5),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: RaisedButton(
                    onPressed: _buttonTapped, child: Text("Invoke Method")),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: RaisedButton(
                    onPressed: () => signalR.subscribeToHubMethod("methodName"),
                    child: Text("Listen to Hub Method")),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.cast_connected),
          onPressed: () async {
            await signalR.connect();
          },
        ),
      ),
    );
  }

  _onStatusChange(String status) {
    if (mounted) {
      setState(() {
        _signalRStatus = status;
      });
    }
  }

  _onNewMessage(dynamic message) {
    print(message);
  }

  _buttonTapped() async {
    final res = await signalR
        .invokeMethod("<Your methodname here>", arguments: ['<Your arguments here>']).catchError((error) {
          print(error.toString());
        });
    final snackBar =
        SnackBar(content: Text('SignalR Method Response: ${res.toString()}'));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
