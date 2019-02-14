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
import com.amazonaws.ClientConfiguration;
import com.amazonaws.regions.Region;
import com.amazonaws.services.lambda.AWSLambdaClient;
import com.amazonaws.services.lambda.model.InvokeRequest;
import com.amazonaws.services.lambda.model.InvokeResult;
import com.amazonaws.AmazonServiceException;
import java.nio.charset.StandardCharsets;



public class LambdaPlugin implements MethodCallHandler {

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "lambda.aws.amazon.com");
    channel.setMethodCallHandler(new LambdaPlugin());
  }
  final private Map<String, AWSLambdaClient> lambdas =
                        new HashMap<>();
  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    switch (call.method) {
      case "configure":
        onConfigure(call,result);
        return;
      case "invoke":
        onInvoke(call,result);
        return;
      default:
        result.notImplemented();
    }
  }
  private void onConfigure(MethodCall call, final Result result) {
      final String accessKey = call.argument("accessKey");
      if (accessKey == null) {
        result.error(null,"missing accessKey:",null);
        return;
      }
      final String secretKey = call.argument("secretKey");
      if (secretKey == null) {
        result.error(null,"missing secretKey:",null);
        return;
      }
      final String regionString = call.argument("region");
      final Region region = Region.getRegion(regionString);
      if (region == null) {
        result.error(null,"unsupported region:" + regionString,null);
        return;
      }
      final String key = call.argument("key");
      if (key == null) {
        result.error(null,"key should not be null",null);
        return;
      }
      BasicAWSCredentials cred = new BasicAWSCredentials(accessKey, secretKey);
      ClientConfiguration conf = new ClientConfiguration().withEnableGzip(true);
      AWSLambdaClient lambda = new AWSLambdaClient(cred,conf);
      lambda.setRegion(region);
      this.lambdas.put(key,lambda);
      result.success(null);
  }
  private void onInvoke(MethodCall call, final Result result) {
    final String name = call.argument("name");
    if (name == null) {
        result.error(null,"lambda: missing name",null);
        return;
    }
    final String jsonString = call.argument("jsonString");
    if (jsonString == null) {
        result.error(null,"lambda: missing jsonString",null);
        return;
    }
    final String key = call.argument("key");
    if (jsonString == null) {
        result.error(null,"lambda: missing key",null);
        return;
    }
    final AWSLambdaClient lambda = this.lambdas.get(key);
    if (lambda == null) {
      result.error(null,"lambda: no client configured for key:"+key,null);
      return;
    }
    new Thread(new Runnable() {
        public void run() {
            InvokeRequest invokeRequest = new InvokeRequest()
                    .withFunctionName(name)
                    .withPayload(StandardCharsets.UTF_8.encode(jsonString));
            try {
                InvokeResult invokeResult = lambda.invoke(invokeRequest);
                String s = StandardCharsets.UTF_8.decode(invokeResult.getPayload()).toString();
                result.success(s);
            } catch (AmazonServiceException e) {
              result.error(e.getErrorCode(), e.getErrorMessage(), null);
            } catch (Exception e) {
              result.error(null, e.getMessage(), null);
            }
        }
    }).start();
  }
}
