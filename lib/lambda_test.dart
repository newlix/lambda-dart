import 'package:testing/testing.dart' as testing;
import 'package:lambda/lambda.dart' as lambda;
import 'dart:convert' show Base64Encoder, Base64Decoder, Utf8Decoder;
import 'package:flutter/services.dart';

const encoder = const Base64Encoder();
const decoder = const Base64Decoder();
String decode(String s) {
  return Utf8Decoder().convert(Base64Decoder().convert(s));
}

final String a = decode("QUtJQUpEREpEWU9OT01LTUxSM0E=");
final String s =
    decode("akJtK2ZqWmZQTmdLOGY3MUxYY2Y2VHBYVmtRcW96QXVFUVdVYXQ4Mg==");
final String r = decode("YXAtbm9ydGhlYXN0LTE=");

testInvokeHello(testing.T t) async {
  await lambda.configure(a, s, r);
  final out = await lambda.invoke("hello", {"name": "tester"});
  if (out != "Hello tester") {
    t.error("out = $out, want Hello tester");
  }
}

testInvokeUnknown(testing.T t) async {
  try {
    await lambda.invoke("unknown", null);
  } on PlatformException catch (e) {
    if (e.code != "ResourceNotFoundException") {
      t.error("error code = ${e.code}, want ResourceNotFoundException");
    }
    if (!e.message.startsWith("Function not found:") &&
        !e.message.endsWith("function:unknown")) {
      t.error(
          "error message = ${e.message}, want Function not found:.*function:unknown");
    }
  } catch (e) {
    t.error("unexpexted error = $e");
  }
}
