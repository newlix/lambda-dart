import 'dart:async';
import 'dart:io';
// Imports the Flutter Driver API
import 'package:flutter_driver/flutter_driver.dart';
// import 'package:test/test.dart';

void main() async {
  final driver = await FlutterDriver.connect();
  final out = await driver.requestData(null);
  driver.close();
  if (out != "pass") {
    exit(-1);
  }
}
