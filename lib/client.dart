import "package:protobuf/protobuf.dart" as protobuf;
import "dart:convert" show Base64Encoder, Base64Decoder;
import 'dart:math' show Random;
import "lambda.dart" as lambda;

const _encoder = const Base64Encoder();
const _decoder = const Base64Decoder();

String random(int length) {
  var rand = new Random();
  var codeUnits = new List.generate(length, (index) {
    return rand.nextInt(33) + 89;
  });

  return new String.fromCharCodes(codeUnits);
}

class Base64Client extends protobuf.RpcClient {
  Base64Client(String accessKey, String secretKey, String region) {
    this.key = random(32);
    lambda.configure(accessKey, secretKey, region, key: this.key);
  }
  String key;
  @override
  Future<T> invoke<T extends protobuf.GeneratedMessage>(
      protobuf.ClientContext ctx,
      String serviceName,
      String methodName,
      protobuf.GeneratedMessage request,
      T emptyResponse) async {
    final payload = _encoder.convert(request.writeToBuffer());
    final out = await lambda.invoke(methodName, payload, key: this.key);
    emptyResponse.mergeFromBuffer(_decoder.convert(out));
    return emptyResponse;
  }
}
