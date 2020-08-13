package com.kangfenmao.nim.model;

import com.alibaba.fastjson.JSON;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.msg.MsgService;
import com.netease.nimlib.sdk.msg.model.IMMessage;

import java.util.ArrayList;
import java.util.List;

public class Message {
  String id;

  public Message(String id) {
    this.id = id;
  }

  public WritableMap getMessage() {
    List<String> uuids = new ArrayList<>();
    uuids.add(this.id);
    List<IMMessage> imMessages = NIMClient.getService(MsgService.class).queryMessageListByUuidBlock(uuids);
    WritableMap message = Arguments.createMap();

    if (imMessages.size() > 0) {
      IMMessage imMessage = imMessages.get(0);
      message.putString("id", imMessage.getUuid());
      message.putString("session_id", imMessage.getSessionId());
      message.putString("session_type", imMessage.getSessionType().toString());
      message.putString("account", imMessage.getFromAccount());
      message.putString("nickname", imMessage.getFromNick());
      message.putString("content", imMessage.getContent());
      message.putString("extension", JSON.toJSONString(imMessage.getRemoteExtension()));
      message.putString("time", String.valueOf(imMessage.getTime()));
      message.putString("type", imMessage.getMsgType().toString());
      message.putString("direct", imMessage.getDirect().toString());
    }

    return imMessages.size() > 0 ? message : null;
  }

  public IMMessage getImMessage() {
    List<String> uuids = new ArrayList<>();
    uuids.add(this.id);
    List<IMMessage> imMessages = NIMClient.getService(MsgService.class).queryMessageListByUuidBlock(uuids);

    return imMessages.size() > 0 ? imMessages.get(0) : null;
  }
}
