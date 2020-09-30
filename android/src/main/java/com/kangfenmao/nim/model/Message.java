package com.kangfenmao.nim.model;

import android.util.Log;

import com.alibaba.fastjson.JSON;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.msg.MsgService;
import com.netease.nimlib.sdk.msg.attachment.FileAttachment;
import com.netease.nimlib.sdk.msg.attachment.ImageAttachment;
import com.netease.nimlib.sdk.msg.constant.MsgTypeEnum;
import com.netease.nimlib.sdk.msg.model.IMMessage;

import java.util.ArrayList;
import java.util.List;

public class Message {
  String id;
  IMMessage message;

  public Message(String id) {
    this.id = id;
  }

  public Message(IMMessage message) {
    this.message = message;
  }

  private WritableMap format(IMMessage imMessage) throws InterruptedException {
    if (imMessage == null) {
      return null;
    }

    WritableMap message = Arguments.createMap();
    message.putString("id", imMessage.getUuid());
    message.putString("session_id", imMessage.getSessionId());
    message.putString("session_type", imMessage.getSessionType().toString());
    message.putString("account", imMessage.getFromAccount());
    message.putString("nickname", imMessage.getFromNick());
    message.putString("avatar", new Contact(imMessage.getFromAccount()).getContact().getString("avatar"));
    message.putString("content", imMessage.getContent());
    message.putString("extension", JSON.toJSONString(imMessage.getRemoteExtension()));
    message.putString("time", String.valueOf(imMessage.getTime()));
    message.putString("type", imMessage.getMsgType().toString());
    message.putString("direct", imMessage.getDirect().toString());

    if (imMessage.getMsgType() == MsgTypeEnum.image) {
      ImageAttachment image = (ImageAttachment) imMessage.getAttachment();
      WritableMap imageMap = Arguments.createMap();
      imageMap.putString("url", image.getUrl());
      imageMap.putString("thumb_url", image.getThumbUrl());
      imageMap.putInt("width", image.getWidth());
      imageMap.putInt("height", image.getHeight());
      message.putMap("image", imageMap);
    }

    return message;
  }

  public WritableMap getMessage() throws InterruptedException {
    return this.format(this.getImMessage());
  }

  public IMMessage getImMessage() {
    if (this.message != null) {
      return this.message;
    }

    List<String> uuids = new ArrayList<>();
    uuids.add(this.id);
    List<IMMessage> imMessages = NIMClient.getService(MsgService.class).queryMessageListByUuidBlock(uuids);

    return (imMessages == null || imMessages.isEmpty()) ? null : imMessages.get(0);
  }

  public String getContentSummary() {
    IMMessage imMessage = this.getImMessage();

    if (imMessage == null) {
      return "";
    }

    return imMessage.getContent();
  }
}
