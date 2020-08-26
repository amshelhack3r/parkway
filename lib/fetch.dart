import 'dart:convert';
import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:parkway/Reading.dart';
import 'dart:async';

import 'package:parkway/db.dart';

const all_readings = "https://mutall.co.ke/parkway/all";
const previous_readings = "https://mutall.co.ke/parkway/previous";
const insert_readings = "https://mutall.co.ke/parkway/insert";


class Fetch {
  DatabaseProvider provider;

  Fetch() {
    provider = new DatabaseProvider();
  }


  getReadings() async {
    try{
      var response = await http.get(all_readings);
      var data = jsonDecode(response.body);
      print(data);
  
    }on SocketException{
      Fluttertoast.showToast(
        msg: "Server Error! Check Internet Connection",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.greenAccent[400],
        textColor: Colors.white,
        fontSize: 16.0);
    }
  }

  Future<Map<String, dynamic>> getLastReading() async{
    try{
      var response = await http.get(previous_readings);
      return jsonDecode(response.body);
      
    }on SocketException{
          Fluttertoast.showToast(
        msg: "Server Error! Check Internet Connection",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.greenAccent[400],
        textColor: Colors.white,
        fontSize: 16.0);
    }
    }
  
  Future<bool> uploadReading(Reading reading) async {
    print(reading);
    try{
    var response = await http.post(insert_readings, body: reading.toMap());
    print(response.body);
    print(response.statusCode);
    if(response.statusCode == 201){
      return true;
    }else{
      return false;
    }
    }on SocketException{
      Fluttertoast.showToast(
        msg: "Server Error! Check Internet Connection",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.greenAccent[400],
        textColor: Colors.white,
        fontSize: 16.0);
  
    }
  }
}
