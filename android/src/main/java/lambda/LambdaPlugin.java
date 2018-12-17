// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package lambda;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.HashMap;
import java.util.Map;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.regions.Region;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.lambda.AWSLambda;
import com.amazonaws.services.lambda.AWSLambdaClient;
import com.amazonaws.services.lambda.model.InvokeRequest;
import com.amazonaws.services.lambda.model.InvokeResult;
import com.amazonaws.AmazonServiceException;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;


public class LambdaPlugin implements MethodCallHandler {

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "lambda.aws.amazon.com");
    channel.setMethodCallHandler(new LambdaPlugin());
  }

  AWSLambda lambda;
  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    switch (call.method) {
      case "configure":
        String accessKey = call.argument("accessKey");
        String secretKey = call.argument("secretKey");
        String region = call.argument("region");
        BasicAWSCredentials c = new BasicAWSCredentials(accessKey, secretKey);
        this.lambda = new AWSLambdaClient(c);
        this.lambda.setRegion(Region.getRegion(region));
        result.success(null);
        break;
      case "invoke":
        final String name = call.argument("name");
        final String jsonString = call.argument("jsonString");
        new Thread(new Runnable() {
            public void run() {
                InvokeRequest invokeRequest = new InvokeRequest()
                        .withFunctionName(name)
                        .withPayload(ByteBuffer.wrap(jsonString.getBytes()));
                InvokeResult invokeResult = null;
                try {
                    invokeResult = lambda.invoke(invokeRequest);
                    String s = StandardCharsets.UTF_8.decode(invokeResult.getPayload()).toString();
                    result.success(s);
                } catch (AmazonServiceException e) {
                  result.error(e.getErrorCode(), e.getErrorMessage(), null);
                } catch (Exception e) {
                  result.error(null, e.getMessage(), null);
                }

            }
        }).start();
        break;
      default:
        result.notImplemented();
    }

  }
}
