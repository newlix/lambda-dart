import 'package:testing/testing.dart' as testing;
import 'package:lambda/lambda.dart' as lambda;
import 'dart:convert' show Base64Encoder, Base64Decoder, Utf8Decoder;

const encoder = const Base64Encoder();
const decoder = const Base64Decoder();
String decode(String s) {
  return Utf8Decoder().convert(Base64Decoder().convert(s));
}

final String a = decode("QUtJQUpEREpEWU9OT01LTUxSM0E=");
final String s =
    decode("akJtK2ZqWmZQTmdLOGY3MUxYY2Y2VHBYVmtRcW96QXVFUVdVYXQ4Mg==");
final String r = decode("YXAtbm9ydGhlYXN0LTE=");

testInovokeHello(testing.T t) async {
  await lambda.configure(a, s, r);
  final out = await lambda.invoke("hello", {"name": "tester"});
  if (out != "Hello tester") {
    t.error("out = $out, want Hello tester");
  }
}
