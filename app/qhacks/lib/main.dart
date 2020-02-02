import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';

final MqttClient client = MqttClient('test.mosquitto.org', '');
String _buttonStatus = null;
String _garageStatus = null;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sGarage',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: MyHomePage(title: 'sGarage'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _isOpen = false;
  bool _isOpenOld = true;
  void _button() {
    const String pubTopic = 'sgarage-p';
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    if (_isOpen) {
      builder.addString('CLOSE');
    } else {
      builder.addString('OPEN');
    }
    print('EXAMPLE::Publishing our lol topic');
    client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload);
  }

  void connectMQTT() async {
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      return;
    }
    client.keepAlivePeriod = 20;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = onDisconnected;
    /// Add the successful connection callback
    client.onConnected = onConnected;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .keepAliveFor(20) // Must agree with the keep alive set above or not set
        .withWillTopic('willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean();
    print('EXAMPLE::Mosquitto client connecting....');
    client.connectionMessage = connMess;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however eill
    /// never send malformed messages.
    try {
      await client.connect();
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      client.disconnect();
    }

    /// Check we are connectedx`
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print(
          'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
    }

    /// Ok, lets try a subscription
    print('EXAMPLE::Subscribing to the test/lol topic');
    const String topic = 'sgarage'; // Not a wildcard topic
    client.subscribe(topic, MqttQos.atMostOnce);
  }

  void onDisconnected() {
    print('disconnected - reconnecting');
    connectMQTT();
  }

  /// The successful connect callback
  void onConnected() {
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
    listenMQTT();
  }

  void listenMQTT() {
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final String pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print(pt);
      if (pt == "0") {
        _isOpen = false;
      } else if (pt == "1"){
        _isOpen = true;
      }

      if (_isOpen != _isOpenOld) {
        _isOpenOld = _isOpen;
        updateStatus();
      }

    });
  }

  void updateStatus() {
    if (_isOpen) {
      _garageStatus = "OPEN";
      _buttonStatus = "CLOSED";
      setState(() {
        _counter++;
      });
    } else {
      _garageStatus = "CLOSED";
      _buttonStatus = "OPEN";
      setState(() {
        _counter++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    connectMQTT();
    return Scaffold(

      appBar: AppBar(

        title: new Center(child: new Text(widget.title, textAlign: TextAlign.center, style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: Colors.white))),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 350.0,
              height: 300.0,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: new BorderRadius.all(
                  new Radius.circular(20.0),
                ),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 5.0,
                ),
              ),
              child: Text(
                'Your Garage Door Status is \n\n $_garageStatus',
                style: TextStyle(fontSize: 50.0, fontFamily: 'Allerta'),
                textAlign: TextAlign.center,

              ),
            ),
            SizedBox(height: 100,),
            Container(
              width: 350.0,
              height: 100.0,
              child: SizedBox(
                width: double.infinity,
                child: RaisedButton(
                  child: Text('$_buttonStatus', style: TextStyle(fontSize: 35.0)),
                  onPressed: _button,
                  color: Colors.green,
                  textColor: Colors.white,
                  padding: const EdgeInsets.all(5.0),
                  splashColor: Colors.lightGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20.0),
                      side: BorderSide(color: Colors.green.withOpacity(1))
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 50),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map, size: 50),
            title: Text('Map'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 50),
            title: Text('Settings'),
          ),
        ],
      ),
    );
  }
}