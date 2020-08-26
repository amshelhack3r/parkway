import 'dart:collection';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parkway/Reading.dart';
import 'package:parkway/fetch.dart';

class ReadingStateful extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ReadingState();
}

class ReadingState extends State<ReadingStateful> {
  var _valueController = TextEditingController();
  Fetch fetch = new Fetch();
  Reading reading;
  var hasLoaded = false;
  bool hasError = false;
  String errorMsg = null;

  calculate() {
    var prevDate = DateTime.parse(reading.date);
    var now = new DateTime.now();
    return now.difference(prevDate).inDays.toString();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        centerTitle: true,
        title: Text("PARKWAY WATER READING"),
      ),
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[_previousValues(), _inputBox()],
      )),
    );
  }

  Widget _previousValues() {
    return FutureBuilder(
      initialData: null,
      future: fetch.getLastReading(),
      builder: (context, AsyncSnapshot<Map> snapshot) {
        Widget _body;
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            _body = Center(child: Text("No Previous Readings"));
          } else {
            reading = Reading.fromMap(snapshot.data);
            var pardedDate = DateTime.parse(reading.date);
            var date = formatDate(pardedDate, [dd,'-',mm,'-',yyyy]);
            var value = reading.value;
            var mobile = reading.mobile;
            var days = calculate();
            _body = Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("PREVIOUS READING $date",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Last Read: ",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("$days days ago",
                          style: TextStyle(
                            fontSize: 22,
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Last Value:",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(value.toString(),
                          style: TextStyle(
                            fontSize: 22,
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Mobile:",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(mobile,
                          style: TextStyle(
                            fontSize: 22,
                          ))
                    ],
                  ),
                ),
              ],
            );
          }
        } else if (snapshot.hasError) {
          _body = Center(
            child: Text(snapshot.error.toString()),
          );
        } else {
          _body = Center(
            child: CircularProgressIndicator(),
          );
        }

        return _body;
      },
    );
  }

  Widget _inputBox() {
    return Card(
        elevation: 4,
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 1.5,
          height: MediaQuery.of(context).size.width / 1.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                "CURRENT READINGS",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              valueInput(),
              RaisedButton(
                padding: EdgeInsets.all(15.0),
                color: Colors.purpleAccent[700],
                textColor: Colors.white,
                onPressed: () async {
                  if (_validate()) {
                    setState(() {
                      hasError = false;
                    });
                    Reading newRead = new Reading(
                        DateTime.now().toString(), _valueController.text);
                        print(newRead);
                    newRead.getDeviceName().then((onValue) {
                      fetch.uploadReading(newRead).then((value) {
                        if (value) {
                          Fluttertoast.showToast(
                              msg: "SUCCESS, Reading Uploaded",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIos: 1,
                              backgroundColor: Colors.greenAccent[400],
                              textColor: Colors.white,
                              fontSize: 16.0);
                          _valueController.clear();
                          setState(() {});
                        }
                      });
                    });
                  }
                },
                child: Text("UPLOAD"),
              )
            ],
          ),
        ));
  }

  Widget valueInput() {
    return Container(
      width: 250,
      child: TextField(
        controller: _valueController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            hintText: "Enter Value",
            labelText: "Enter Value",
            errorText: hasError ? errorMsg : null,
            border: OutlineInputBorder()),
      ),
    );
  }

  bool _validate() {
    bool valid = true;
    if (_valueController.text.isEmpty) {
      valid = false;
      setState(() {
        hasError = true;
        errorMsg = "Value cannot be empty";
      });
    } else {
      if (reading == null) {
        return valid;
      }
      if (double.parse(reading.value) > double.parse(_valueController.text)) {
        valid = false;
        setState(() {
          hasError = true;
          errorMsg = "Value cannot be smaller than last";
        });
      }
    }
    return valid;
  }
}
