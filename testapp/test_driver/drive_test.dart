import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';

void main() async {
  final driver = await FlutterDriver.connect();
  final pass = await driver.requestData(null) == "true";
  driver.close();
  if (!pass) {
    exit(-1);
  }
}
