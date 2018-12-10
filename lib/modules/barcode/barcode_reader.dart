import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BarCodeReader extends StatefulWidget {
  @override
  _BarCodeReaderState createState() => new _BarCodeReaderState();
}

class _BarCodeReaderState extends State<BarCodeReader> {
  String barcode = "";

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Barcode Scanner'),
            centerTitle: true,
            backgroundColor: Colors.red,
          ),
          body: new Center(
            child: new Column(
              children: <Widget>[
                new Container(
                  child: new RaisedButton(
                    onPressed: scan,
                    child: new Text("Scan",style: TextStyle(fontSize: 24.0, color: Colors.white),),
                    color: Colors.red,
                  ),
                  padding: const EdgeInsets.all(40.0),
                ),
                new Text(barcode),
              ],
            ),
          )),
    );
  }

  @override
  initState() {
    super.initState();
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
}
