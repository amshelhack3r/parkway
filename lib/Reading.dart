import 'package:date_format/date_format.dart';
import 'package:device_info/device_info.dart';

class Reading {
  String date;
  String mobile;
  String value;
  String timestamp;

  Reading(this.date, this.value){
    this.timestamp = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
  }

  Future<String> getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    this.mobile = androidInfo.model;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'date': date, 'mobile': mobile, 'value': value, 'timestamp':timestamp};
    return map;
  }

  Reading.fromMap(Map<String, dynamic> map) {
    date = map['date'];
    mobile = map['mobile'];
    value = map['value'].toString();
  }

  @override
  String toString() {
    // TODO: implement toString
    return "DATE: $date, VALUE: $value, MOBILE: $mobile, timestamp: $timestamp";
  }
}
