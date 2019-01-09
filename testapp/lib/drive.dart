import 'package:lambda/tests.dart' as tests;
import 'package:flutter_driver/driver_extension.dart';
import 'package:testing/testing.dart' as testing;

void main() async {
  enableFlutterDriverExtension(handler: (s) async {
    final pass = await tests.pass(verbose: true);
    return "$pass";
  });
}
