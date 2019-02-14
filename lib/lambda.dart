// Copyright 2018, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

import 'dart:io' show Platform;
import 'dart:convert' show jsonEncode, jsonDecode;

export "client.dart";

const MethodChannel _channel = MethodChannel('lambda.aws.amazon.com');

Future<dynamic> configure(String accessKey, String secretKey, String region,
    {String key = ""}) async {
  final dynamic response =
      await _channel.invokeMethod("configure", <String, dynamic>{
    "accessKey": accessKey,
    "secretKey": secretKey,
    "region": region,
    "key": key,
  });
  return response;
}

Future<dynamic> invoke(String name, dynamic jsonObject,
    {String key = ""}) async {
  if (Platform.isAndroid) {
    final jsonString = jsonEncode(jsonObject);
    final dynamic response =
        await _channel.invokeMethod("invoke", <String, dynamic>{
      "name": name,
      "jsonString": jsonString,
      "key": key,
    });
    return jsonDecode(response);
  } else {
    final dynamic response =
        await _channel.invokeMethod("invoke", <String, dynamic>{
      "name": name,
      "jsonObject": jsonObject,
      "key": key,
    });
    return response;
  }
}
