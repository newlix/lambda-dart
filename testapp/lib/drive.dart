import 'package:lambda/tests.dart' as tests;
import 'package:flutter_driver/driver_extension.dart';
import 'package:testing/testing.dart' as testing;

void main() async {
  enableFlutterDriverExtension(handler: (s) async {
    await tests.run();
    return testing.errorCount == 0 ? "pass" : null;
  });
}
