import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
  bool _status = false;
  String _buttonStatus = null;
  String _garageStatus = null;
  void _button() {
    if(_status){
      _buttonStatus = "Close";
      _garageStatus = "Open";
    }
    else if(!_status) {
      _buttonStatus = "Open";
      _garageStatus = "Close";
    }
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: new Center(child: new Text(widget.title, textAlign: TextAlign.center, style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: Colors.white))),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Your Garage Door is ',
              style: TextStyle(fontSize: 25.0),
            ),
            Text(
              '$_garageStatus',
               style: TextStyle(fontSize: 50.0),
            ),
            RaisedButton(
              child: Text('$_buttonStatus', style: TextStyle(fontSize: 25.0)),
              onPressed: _button,
              color: Colors.green,
              textColor: Colors.white,
              padding: const EdgeInsets.all(10.0),
              splashColor: Colors.lightGreen,
            ),

            /*Container(
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
              ),
              child: Text(
                'Your Garage Door is ',
                style: TextStyle(fontSize: 25.0),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
