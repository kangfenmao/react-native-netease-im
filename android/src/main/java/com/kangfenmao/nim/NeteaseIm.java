package com.kangfenmao.nim;

import android.content.Context;

import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.SDKOptions;
import com.netease.nimlib.sdk.mixpush.MixPushConfig;

public class NeteaseIm {
  static public void init(Context context, String appKey) {
    SDKOptions options = new SDKOptions();
    options.appKey = appKey;
    NIMClient.init(context, null, options);
  }

  static public void init(Context context, String appKey, MixPushConfig mixPushConfig) {
    SDKOptions options = new SDKOptions();
    options.appKey = appKey;
    options.mixPushConfig = mixPushConfig;

    if (mixPushConfig.hwAppId != null) {
      //
    }

    NIMClient.init(context, null, options);
  }
}
