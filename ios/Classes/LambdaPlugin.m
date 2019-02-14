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
        NSString *key = call.arguments[@"key"];
        AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:accessKey secretKey:secretKey];
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc]initWithRegion:region.aws_regionTypeValue credentialsProvider:credentialsProvider];
        
        if (key.length == 0) {
            [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
        } else {
            [AWSLambdaInvoker registerLambdaInvokerWithConfiguration:configuration forKey:key];
        }
        result(nil);
        return;
    }else if ([@"invoke" isEqualToString:call.method]) {
        NSString *key = call.arguments[@"key"];
        NSString *name = call.arguments[@"name"];
        NSObject *jsonObject = call.arguments[@"jsonObject"];
        AWSLambdaInvoker *invoker = AWSLambdaInvoker.defaultLambdaInvoker;
        if (key.length == 0) {
            invoker = [AWSLambdaInvoker LambdaInvokerForKey:key];
        }
        if (invoker == nil) {
            NSString *message = [NSString stringWithFormat:@"no invoker registered for key:%@",key];
            result([FlutterError errorWithCode:name  message:message details:nil]);
            return;
        }
        [invoker invokeFunction:name JSONObject:jsonObject completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
          if (error == nil) {
              result(response);
              return;
          }else{
              NSString *message = error.userInfo[@"errorMessage"];
              if (message.length == 0) {
                  message = @"";
              }
              result([FlutterError errorWithCode:name  message:message details:error.userInfo]);
              return;
          }
      }];
  } else {
      result(FlutterMethodNotImplemented);
      return;
  }
}

@end
