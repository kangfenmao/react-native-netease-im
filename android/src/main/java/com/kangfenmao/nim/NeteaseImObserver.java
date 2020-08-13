package com.kangfenmao.nim;

import androidx.annotation.Nullable;

import com.alibaba.fastjson.JSON;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.kangfenmao.nim.model.Message;
import com.kangfenmao.nim.utils.Utils;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.Observer;
import com.netease.nimlib.sdk.StatusCode;
import com.netease.nimlib.sdk.auth.AuthServiceObserver;
import com.netease.nimlib.sdk.msg.MsgServiceObserve;
import com.netease.nimlib.sdk.msg.model.IMMessage;
import com.netease.nimlib.sdk.msg.model.RecentContact;

import java.util.List;
import java.util.Map;

public class NeteaseImObserver {
  ReactContext reactContext;

  public NeteaseImObserver(ReactContext reactContext) {
    this.reactContext = reactContext;
  }

  /**
   * 事件提交
   *
   * @param eventName
   * @param params
   */
  private void sendEvent(String eventName, @Nullable WritableMap params) {
    this.reactContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
      .emit(eventName, params);
  }

  /**
   * 事件提交
   *
   * @param eventName
   * @param array
   */
  private void sendEvent(String eventName, @Nullable WritableArray array) {
    this.reactContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
      .emit(eventName, array);
  }

  /**
   * 添加新消息监听
   */
  public void addIncomingMessagesObserver() {
    Observer<List<IMMessage>> incomingMessageObserver =
      new Observer<List<IMMessage>>() {
        @Override
        public void onEvent(List<IMMessage> imMessages) {
          // 处理新收到的消息，为了上传处理方便，SDK 保证参数 messages 全部来自同一个聊天对象。
          WritableArray messages = Arguments.createArray();

          for (int i = 0; i < imMessages.size(); i++) {
            Message message = new Message(imMessages.get(i));
            messages.pushMap(message.getMessage());
          }

          sendEvent("onMessages", messages);
        }
      };

    NIMClient.getService(MsgServiceObserve.class).observeReceiveMessage(incomingMessageObserver, true);
  }

  /**
   * 添加连接状态监听
   */
  public void addConnectStatusObserver() {
    Observer observer = new Observer<StatusCode>() {
      public void onEvent(StatusCode status) {
        WritableMap params = Arguments.createMap();
        Map connectStatus = Utils.getStatusMap(status);
        params.putString("code", (String) connectStatus.get("code"));
        params.putString("message", (String) connectStatus.get("message"));
        sendEvent("onConnectStatusChanged", params);
      }
    };

    NIMClient.getService(AuthServiceObserver.class).observeOnlineStatus(observer, true);
  }

  /**
   * 添加最近会话监听
   */
  public void addRecentContactObserver() {
    //  创建观察者对象
    Observer<List<RecentContact>> messageObserver = new Observer<List<RecentContact>>() {
      @Override
      public void onEvent(List<RecentContact> messages) {
        sendEvent("onConversationsChanged", Utils.getConversationsFromRecentContacts(messages));
      }
    };

    //  注册观察者
    NIMClient.getService(MsgServiceObserve.class).observeRecentContact(messageObserver, true);
  }
}
