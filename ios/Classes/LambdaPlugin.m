// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "LambdaPlugin.h"

#import <AWSLambda/AWSLambda.h>


@interface LambdaPlugin ()
@property(nonatomic, retain) FlutterMethodChannel *_channel;
@end

@implementation LambdaPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"lambda.aws.amazon.com"
                                  binaryMessenger:[registrar messenger]];
  LambdaPlugin *instance = [[LambdaPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
  self = [super init];
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"configure" isEqualToString:call.method]) {
        NSString *accessKey = call.arguments[@"accessKey"];
        NSString *secretKey = call.arguments[@"secretKey"];
        NSString *region = call.arguments[@"region"];
        AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:accessKey secretKey:secretKey];
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc]initWithRegion:region.aws_regionTypeValue credentialsProvider:credentialsProvider];
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
        result(nil);
    }else if ([@"invoke" isEqualToString:call.method]) {
        NSString *name = call.arguments[@"name"];
        NSObject *jsonObject = call.arguments[@"jsonObject"];
        [AWSLambdaInvoker.defaultLambdaInvoker invokeFunction:name JSONObject:jsonObject completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
          if (error == nil) {
              result(response);
          }else{
              NSString *code = error.userInfo[@"NSLocalizedFailureReason"];
              NSString *message = error.userInfo[@"Message"];
              result([FlutterError errorWithCode:code  message:message details:error.userInfo]);
          }
      }];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
